# Sturcture of a rust project

## The Beginning of the Rust project

You can initialize a rust project by using:

```
cargo init
```

## Source Code

### Crate and Module

Source code is laid in the directory 'src'. And you can write your code in the src. And the content in 'src' is a crate.

For a professional programer, different model for diffrent functions should be divided into different directories. 

In Rust, a directory is considered a module, and you can use a 'mod.rs' file to control which functions, traits, or structs can be referenced by other modules in the project.

Assuming that you develop some tool functions for main.rs, you can write a line to references the function fn_add:

```
mod tools
use crate::tools::fn_add
```

`mod tools` is for declaring the module in the file, and `use crate::tools::fn_add` is for import the function to be used.

And the `fn_add` must use be a public function with 'pub' at the beginning of definition in file 'tools/mod.rs'.

```
pub fn fn_add (a: i32, b: i32) -> i32 {
    a + b
}
```

### Module Group

In Rust, a module can contain multiple sub-modules. For example, a module named 'tools' can include sub-modules named 'add' and 'div'. The content of these sub-modules is defined in separate files named 'add.rs' and 'div.rs', respectively. It is important to ensure that the name of the module is consistent with the name of its corresponding file.

You can declare the contained modules in 'tools/mod.rs'.

```
mod div;
mod add;

pub use add::fn_add;
pub use add::fn_div;
```

And you can reference the `fn_add` in 'main.rs' by 
```
mod tools;
use crate::tools::fn_add;
```

The following combination is also possible.

```
// tools/mod.rs
pub mod div;
pub mod add;
```

```
// main.rs
mod tools;
use crate::tools::add::fn_add;
```


## Dependency

A project usually depend some third-party libraries. The file `Cargo.toml` is the handle to manage the dependencies.