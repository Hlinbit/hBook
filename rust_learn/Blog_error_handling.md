任何软件都不可能在理想环境中运行，这意味着错误往往会不期而至。内存不足，网络失败，异常输入等等问题，时刻威胁着软件的正常运行。好的软件会再迭代中会不断在这些可能出错的位置打上补丁，达成尽可能长时间的稳定运行。

而这些补丁就是错误处理逻辑。翻开任意一个成功开源软件的源代码，我们可以发现，真正的核心逻辑其实并不多，而与处理各种异常的代码往往随处可见。正是这些异常处理的逻辑，构成了软件稳定运行的关键。

对于不同的编程语言，受限于提供的语法规则和语言特性，往往会发展出不同的错误处理方式。例如在C语言中，通常通过返回值来表明函数调用是否失败：

```C
ssize_t bytes = fd->read(fd, buf, buflen);
if (bytes < 0) {
    if (bytes < 0){
        // logic to handle read errors.
        return bytes;
    }
}

int n = send(sock, buf, buflen, 0);
if (n < 0) {
    if ( e == EPIPE || e == ECONNRESET ) {
        // logic to handle send errors.
        return n;
    }
}
// ....
return n;
```
上面的代码首先读取文件内容，然后向`sock`套接字接口写入数据，如果读文件或者数据发送失败，会返回一个负数，表明`read`或`send`过程中发生错误。通过检查返回值的具体值，可以得到具体的错误原因，根据原因执行相应的错误处理逻辑。并在最后返回错误码，给为上层函数处理提供依据。

通过C语言提供的错误处理范式，我们可以得到错误处理需要提供的基本能力：
- 可以在代码中识别是否发生错误。
- 明确的展示错误产生的原因。
- ...

尽管C语言提供了这两种能力，但是这样的错误处理模式也有很多的不便。例如：
- 无法直观得到错误的原因。
- 调用栈上的每一层函数都需要通过`if`判断是否存在错误，不够简洁。
- 通过int类型表示错误，容易造成无法分辨错误类型（读文件错误还是发送错误？）。

为了让错误处理更加的科学合理，rust采用了一套特别设计的错误处理范式，较好的解决了以上几个问题。在rust错误处理中，支持以及其简洁的方式检查是否存在错误，并返回错误。

同时rust给编程者提供了定制错误信息和错误类型的能力。使用者不再局限于使用系统或者开发库提供的错误信息，而是可以根据自己的实际需求来展示错误信息，极大地便利了使用者定位错误的能力。

# Rust错误处理

## 一个C语言风格的错误处理

由于rust语言那特殊的语法并不易被初学者接受，为了方便理解，我们按照C语言的逻辑来写一个包含错误处理的函数。

```rust
fn read_file_contents(filename: &str) -> String {
    let mut contents = String::new();
    if let Ok(mut file) = File::open(filename) {
        if let Ok(_) = file.read_to_string(&mut contents) {
            return contents;
        } else {
            return contents;
        }
    } else {
        return contents;
    }
}
```
按照C语言的逻辑，我们应该按照`执行-检查`这一个基本流程进行错误处理。首先通过`File::open`打开文件，然后`file.read_to_string`读取文件。这两个函数的函数签名如下：

```rust
pub fn open<P: AsRef<Path>>(path: P) -> io::Result<File>

fn read_to_string(&mut self, buf: &mut String) -> io::Result<usize>
```
这里涉及到一个非常关键的类型`Result`。Result 是 Rust 标准库中的一个枚举类型，用于表示操作的结果。它有两个变体：
- Ok(T)：表示操作成功，并包含一个值 T。
- Err(E)：表示操作失败，并包含一个错误 E。

如果想要深入了解可以查看官方文档[Result](https://doc.rust-lang.org/book/ch09-02-recoverable-errors-with-result.html)，在这里我们只需要知道它的两个变体即可。

在代码中我们嵌套了两层`if-else`。当结果为`Ok`时，代码将会获取Ok变量的内部值，进入`if`分支。当结果不为`Ok`时，则进入else分支。简单来说：当函数返回值匹配`Ok`时，表明没有错误，反之则有错误。

然而这样的代码丢失了错误的信息，失去了错误处理的关键能力：明确的展示错误产生的原因。因此根据C语言的错误处理思路来写rust的错误处理逻辑并不合适。我们需要rust提供的特性写出更加简洁，更加合理的错误处理逻辑。

## 一个Rust风格的错误处理逻辑

Rust为我们及其简洁的`判断-返回`的错误处理模式。只需要一个`?`就可以完成复杂的错误处理流程。

```rust
fn read_file_contents(filename: &str) -> Result<String, io::Error> {
    let mut contents = String::new();
    let mut file = File::open(filename)?;
    file.read_to_string(&mut contents)?;
    return Ok(String::from(contents));
}
```

让我们仔细解析上面的例子，

`let mut file = File::open(filename)?;`

这行代码中，实现了：
- 判断是否出错
- 出错的情况下：将`Result`类型的错误返回。
- 没有出错的情况，将Ok中的值，赋值给file变量。

一个小小的`?`实现了如此丰富的功能，不得不叹服rust错误处理的简洁。同样`file.read_to_string(&mut contents)?;`也是类似的逻辑，不同之处是，我们不需要`read_to_string`的返回值。

## 定制rust的错误

定制错误在一些新的语言中并不少见。在golang中，我们可以通过实现`error`接口，定义符合需求的定制错误类型，通过调用`Error()`获取具体错误的内容。

为什么我们需要定制化的错误？

很重要的原因是，依赖库的报错信息往往对用户并不友好，通过结合原始的报错信息和具体的项目代码，我们可以给出一个更加有针对性的报错信息，有利于用户和程序员进行查错。

下面是一个定制化的错误类型，主要面向文件IO时可能出现的错误：

```rust
use thiserror::Error;
#[derive(Debug, Error)]
enum MyError {
    #[error("IO error: {0}")]
    Io(#[from] std::io::Error),
    #[error("Item {0} not found")]
    NotFound(String),
    #[error("Item {0} Permission denied")]
    PermissionDenied(String),
}
```

在这里，我们借助了`thiserror`这个第三方库。这个错误中，我们覆盖了找不到文件，权限不足和其他错误。在代码中我们可以通过`map_err`来捕获返回的error，并将其映射到我们自定义的error上。具体操作如下：

```rust
fn map_io_err (err: std::io::Error, name: String) -> MyError {
    match err.kind() {
        io::ErrorKind::NotFound => MyError::NotFound(name),
        io::ErrorKind::PermissionDenied => MyError::PermissionDenied(name),
        _ => MyError::Io(err),
    }
}

// Example function that returns a Result using the custom error type
fn read_file_contents(filename: &str) -> Result<String, MyError> {
    let mut contents = String::new();
    let mut file = File::open(filename).map_err(|e| map_io_err(e, String::from(filename)))?;
    file.read_to_string(&mut contents).map_err(|e| map_io_err(e, String::from(filename)))?;
    Ok(contents)
}
```

`map_err`的函数签名如下：

`pub fn map_err<F, O: FnOnce(E) -> F>(self, op: O) -> Result<T, F>`

它接受一个一次性的闭包，这个闭包的将一个`Err`映射为另一个`Err`。在上面的例子中这个闭包是`|e| map_io_err(e, String::from(filename))`。这个闭包捕捉错误`e`，并调用错误映射函数`map_io_err`。`map_io_err`函数将错误`e`结合文件名`filename`，生成新的`MyError`。


