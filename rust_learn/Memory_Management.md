# Smart Point in rust

## Box




The most straightforward smart pointer is a box, whose type is written `Box<T>`. Boxes allow you to store data on the heap rather than the stack.

## Treating a Type Like a Reference by Implementing the Deref Trait

Implementing the Deref trait allows you to customize the behavior of the dereference operator `*`.

In rust, the variable with type `Box<T>` can be treated as a normal referenc. The reason is that `Box` implements the trait `Deref`. Here is an example.

```rust
fn main() {
    let x = 5;
    let y = Box::new(x);

    assert_eq!(5, x);
    assert_eq!(5, *y);
}
``` 

The type implementing `Deref` enables us to use the dereference operator by defining our own type.

```rust
use std::ops::Deref;

struct MyBox<T>(T);

impl<T> Deref for MyBox<T> {
    type Target = T;

    fn deref(&self) -> &Self::Target {
        &self.0
    }
}

fn main() {
    let x = 5;
    let y = Box::new(x);

    assert_eq!(5, x);
    assert_eq!(5, *y);
}
```

Without the `Deref` trait, the compiler can only dereference `&` references. The `deref` method gives the compiler the ability to take a value of any type that implements Deref and call the deref method to get a `&` reference that it knows how to dereference.

Please pay attention to the return value of `deref`. It is a plain reference to `Target`. If the deref method returned the value directly instead of a reference to the value, the value would be moved out of self. We don’t want to take ownership of the inner value inside `MyBox<T>` in this case or in most cases where we use the dereference operator.

### Deref coercion 

Deref coercion converts a reference to a type that implements the Deref trait into a reference to another type. For example, deref coercion can convert &String to &str because String implements the Deref trait such that it returns &str. 

Deref coercion is a convenience Rust performs on arguments to functions and methods, and works only on types that implement the Deref trait. Deref coercion was added to Rust so that programmers writing function and method calls don’t need to add as many explicit references and dereferences with & and *.

```rust
use std::ops::Deref;

struct MyBox<T>(T);

impl<T> Deref for MyBox<T> {
    type Target = T;

    fn deref(&self) -> &Self::Target {
        &self.0
    }
}

fn hello(name: &str) {
    println!("Hello, {name}!");
}

fn main() {
    let m = MyBox::new(String::from("Rust"));
    hello(&m);
}s
```
Here we’re calling the hello function with the argument `&m`, which is a reference to a `MyBox<String>` value. Because we implemented the `Deref` trait on `MyBox<T>`, Rust can turn `&MyBox<String>` into `&String` by calling `deref`. The standard library provides an implementation of `Deref` on `String` that returns a string slice, and this is in the API documentation for `Deref`. Rust calls `deref` again to turn the `&String` into `&str`, which matches the hello function’s definition.

When the `Deref` trait is defined for the types involved, Rust will analyze the types and use `Deref::dere`f as many times as necessary to get a reference to match the parameter’s type. The number of times that `Deref::deref` needs to be inserted is resolved at compile time, so there is no runtime penalty for taking advantage of deref coercion!


### `DerefMut` for Interacts with Mutability

Similar to how you use the `Deref` trait to override the * operator on immutable references, you can use the `DerefMut` trait to override the * operator on mutable references.

Rust does deref coercion when it finds types and trait implementations in three cases:

- From &T to &U when T: Deref<Target=U>
- From &mut T to &mut U when T: DerefMut<Target=U>
- From &mut T to &U when T: Deref<Target=U>

## Rc

You have to enable multiple ownership explicitly by using the Rust type `Rc<T>`, which is an abbreviation for reference counting. The `Rc<T>` type keeps track of the number of references to a value to determine whether or not the value is still in use. If there are zero references to a value, the value can be cleaned up without any references becoming invalid.

Note that Rc<T> is only for use in single-threaded scenarios. Via immutable references, Rc<T> allows you to share data between multiple parts of your program for reading only. 

Here is an example to demonstrate the necessity of `Rc<T>`:

```rust
enum List {
    Cons(i32, Box<List>),
    Nil,
}

use crate::List::{Cons, Nil};

fn main() {
    let a = Cons(5, Box::new(Cons(10, Box::new(Nil))));
    let b = Cons(3, Box::new(a));
    let c = Cons(4, Box::new(a));
}
```

In this example. The Cons variants own the data they hold, so when we create the b list, a is moved into b and b owns a. Then, when we try to use a again when creating c, we’re not allowed to because a has been moved.

Instead, we’ll change our definition of List to use `Rc<T>` in place of `Box<T>`

```rust
enum List {
    Cons(i32, Rc<List>),
    Nil,
}

use crate::List::{Cons, Nil};
use std::rc::Rc;

fn main() {
    let a = Rc::new(Cons(5, Rc::new(Cons(10, Rc::new(Nil)))));
    let b = Cons(3, Rc::clone(&a));
    let c = Cons(4, Rc::clone(&a));
}
```

When we create b and c, we call the `Rc::clone` function and pass a reference to the `Rc<List>` in a as an argument. 
s
The implementation of `Rc::clone` doesn’t make a deep copy of all the data like most types’ implementations of clone do. The call to `Rc::clone` only increments the reference count, which doesn’t take much time. 

`Rc::strong_count()` can capture the strong reference count of a `Rc<T>` variable.

## RefCell

Interior mutability is a design pattern in Rust that allows you to mutate data even when there are immutable references to that data; normally, this action is disallowed by the borrowing rules. To mutate data, the pattern uses unsafe code inside a data structure to bend Rust’s usual rules that govern mutation and borrowing. 


# Arc
In Rust, Arc (short for Atomic Reference Counting) is a smart pointer used for shared ownership. It allows multiple owners to access the same data and manages memory deallocation through tracking reference counts. Arc is commonly used for data sharing in multi-threaded environments as it is thread-safe.

To use Arc, you need to import the Arc module:
```
use std::sync::Arc;
```
or 
```
use alloc::sync::Arc;
```
when you cannot use `std` crate in some scenes.

## How to use `Arc`

This is an example for `Arc` which explains some common methods in `Arc`.

It's important to note that the Arc::get_mut() method only returns a mutable reference if the reference count of the Arc is 1. Otherwise, it returns None.


``` rust
use std::sync::Arc;
#[derive(Debug, Clone, Default)]
struct MyStruct {
    pub value: i32,
}

fn main() {
    // Creates a mutable MyStruct instance with the value field set to 42.
    let mut s1 = MyStruct { value: 42 };
    // Wraps s1 in an Arc and assigns it to as1.
    let mut as1 = Arc::new(s1);

    //  Clones the Arc to create ref1 and ref2, other two ownership references to the same data.
    let ref1 = Arc::clone(&as1);
    let ref2 = Arc::clone(&as1);

    println!("ref1 = {:?}", ref1);
    println!("ref2 = {:?}", ref2);

    println!("ref1 reference count = {}", Arc::strong_count(&ref1));
    println!("ref2 reference count = {}", Arc::strong_count(&ref2));
    println!("as1 reference count = {}", Arc::strong_count(&as1));

    // if let Some(mref) = Arc::get_mut(&mut as1) { ... }: Attempts to obtain 
    // a mutable reference to the value inside as1 using Arc::get_mut()
    // However, since the reference count of as1 does not equal to 1,
    // The result of get_mut() is None. The code in if branch will not
    // be executed.
    if let Some(mref) = Arc::get_mut(&mut as1) {
        mref.value = 33;
        println!("mref = {:?}", mref);
    }

    println!("ref1 = {:?}", ref1);
    println!("ref2 = {:?}", ref2);
}

/*
ref1 = MyStruct { value: 42 }
ref2 = MyStruct { value: 42 }
ref1 reference count = 3
ref2 reference count = 3
as1 reference count = 3
ref1 = MyStruct { value: 42 }
ref2 = MyStruct { value: 42 }
*/
```

## Move Semantics for `Arc`
`Arc` does not implement the trait `Copy`. So when a `Arc` object is used as a function input. It's ownership will be moved into invoked function. 


In function `to_num`, `ms` is returned when `value` in `My_Struct` can be converted to a number. In this case, the function  `to_num` change the ownership of `Arc<MyStruct>` from `as1` to `res`. 

```rust
use std::sync::Arc;
#[derive(Debug, Clone, Default)]
struct MyStruct {
    pub value: String,
}

fn to_num(mut ms: Arc<MyStruct>) -> Option<Arc<MyStruct>>{
    let parsed_number: Result<i32, _> = ms.value.parse();
    println!("count in to_num = {}", Arc::strong_count(&ms));
    if let Ok(number) = parsed_number {
        return Some(ms);
    }
    None
}

fn main() {
    let s1 = MyStruct { value: String::from("44") };
    let mut as1: Arc<MyStruct> = Arc::new(s1);

    if let Some(res) = to_num(as1) {
        println!("res = {:?}", res);
        println!("count in main = {}", Arc::strong_count(&res));
    }
    else {
        println!("res not a number");
    }
}

/*
count in to_num = 1
res = MyStruct { value: "44" }
count in main = 1
*/
```