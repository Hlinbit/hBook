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


## Cargo.toml"Introduction

"Cargo.toml" is an important file used for managing project dependencies and build configurations in the Rust programming language. It is a plain text file that is typically located in the project's root directory.

In the "Cargo.toml" file, you can specify the
* **project's name**, 
* **version number**,  
* **author information**, 
* **dependencies**,
* **configuration for building and testing**, 

among other information. This information is used for building and managing Rust projects.

### Package information in cargo.toml

```
[package]
name = "test"
version = "0.1.0"
authors = ["Lei Hou <hlinbit@yeah.net>"]
edition = "2021"
```

The `[package]` part config the project name, version, author, and rust version for the project.


### Dependency in cargo.toml

```
riscv = { git = "https://github.com/rcore-os/riscv", features = ["inline-asm"] }
virtio-drivers = { git = "https://github.com/rcore-os/virtio-drivers", rev = "4ee80e5" }
toolbox = { path = "../toolbox" }
log = "0.4"
sbi-rt = { version = "0.0.2", features = ["legacy"] }
```

The example shows five different dependency condition.

The first one imports a dependency called riscv. The given GitHub link specifies the location of the dependency library for Rust. `features = ["inline-asm"]` specifies that the project use the `inline-asm` feature in the dependency. 


`virtio-drivers` is the second dependency. 
The given GitHub link specifies the location of the dependency library for Rust, and it also provides the commit hash code to specify the version of the dependency.

`toolbox` is a local dependency. To import external dependencies, specify the path where the dependencies are located. The external dependencies must have the "name" attribute set to "toolbox" in `[package]`.

`sbi-rt` and `log` are available on the crates.io registry. Crates.io is the default package registry for Rust, where you can find and share Rust crates/libraries. And we use the feature `legacy` of `sbi-rt`.

### Profile in cargo.toml

In the Cargo.toml file of a Cargo project, you can define profiles for different build configurations. Common configurations include `[profile.dev]` (for development/debug build settings) and `[profile.release]` (for release build settings).

These configurations allow you to define build options such as optimization level, enabling or disabling debug information, code generation options, and more.

This is an example:

```
[profile.release]
opt-level = 3
debug = false
panic = 'abort'
rpath = true
```

* `opt-level = 3` indicates setting the optimization level to 3, which enables a higher degree of optimization to generate higher-performance code.

* `debug = false` means disabling the generation of debug information to reduce the size of the executable file.

* `rpath = true` signifies enabling runtime library path lookup, allowing the executable file to correctly find the dependencies' dynamic libraries at runtime.

* `panic = 'abort'` configures the panic option as "abort". This means that in a release build, when a panic occurs, the program will immediately terminate without performing backtraces and stack unwinding operations.

### `Feature` in cargo.toml

The features section in `Cargo.toml` allows you to define and enable optional features for your crate.

Optional features provide a way to include or exclude certain parts of your crate's functionality. By defining features, you can create different combinations of dependencies or enable specific code paths based on user preferences or specific use cases.

This is an example:

First, let's set up the project structure:

```
my_crate/
  |- src/
      |- main.rs
  |- Cargo.toml
```
Inside the Cargo.toml file, you define the dependencies and features:
```
[package]
name = "my_crate"
version = "0.1.0"
edition = "2021"

[dependencies]
rand = "0.8"

[features]
bubble_sort = [] # No additional dependencies for bubble_sort
quick_sort = ["rand"] # quick_sort depends on the `rand` crate
```

Now, in the src/main.rs file, you can conditionally include the sorting algorithms based on the enabled features:

```
#[cfg(feature = "bubble_sort")]
mod sorting {
    pub fn sort(data: &mut [i32]) {
        // Bubble Sort implementation
        // ...
    }
}

#[cfg(feature = "quick_sort")]
mod sorting {
    extern crate rand;

    use rand::Rng;

    pub fn sort(data: &mut [i32]) {
        // Quick Sort implementation
        // ...
    }
}

fn main() {
    let mut data = [5, 2, 9, 1, 3];
    
    #[cfg(feature = "bubble_sort")]
    sorting::sort(&mut data);

    #[cfg(feature = "quick_sort")]
    sorting::sort(&mut data);
    
    println!("Sorted data: {:?}", data);
}

```

In this example, we have two modules inside the sorting module, each corresponding to a specific sorting algorithm. The `bubble_sort` module is enabled when the `bubble_sort` feature is enabled, and the `quick_sort `module is enabled when the `quick_sort` feature is enabled.

Inside the main function, we conditionally call the sort function based on the enabled features. So, when you build the project with different features, the appropriate sorting algorithm will be used.

To build the project with the bubble_sort feature, use the following command:

```
cargo build --features bubble_sort
```

To build the project with the quick_sort feature, use the following command:
```
cargo build --features quick_sort
```