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

With references and `Box<T>`, the borrowing rules’ invariants are enforced at compile time. With `RefCell<T>`, these invariants are enforced at runtime. With references, if you break these rules, you’ll get a compiler error. With `RefCell<T>`, if you break these rules, your program will panic and exit.

Here is a recap of the reasons to choose Box<T>, Rc<T>, or RefCell<T>:

- `Rc<T>` enables multiple owners of the same data; `Box<T>` and `RefCell<T>` have single owners.
- Box<T> allows immutable or mutable borrows checked at compile time; `Rc<T>` allows only immutable borrows checked at compile time; `RefCell<T>` allows immutable or mutable borrows checked at runtime.
- Because `RefCell<T>` allows mutable borrows checked at runtime, you can mutate the value inside the `RefCell<T>` even when the `RefCell<T>` is immutable.


##  Creating immutable and mutable references from `RefCell<T>`

When creating immutable and mutable references, we use the & and &mut syntax, respectively. With `RefCell<T>`, we use the  `borrow` and `borrow_mut` methods, which are part of the safe API that belongs to `RefCell<T>`. 

The `RefCell<T>` keeps track of how many `Ref<T>` and `RefMut<T>` smart pointers are currently active. Every time we call borrow, the `RefCell<T>` increases its count of how many immutable borrows are active. When a `Ref<T>` value goes out of scope, the count of immutable borrows goes down by one. Just like the compile-time borrowing rules, `RefCell<T>` lets us have many immutable borrows or one mutable borrow at any point in time.

This is an example. `LimitTracker` is tracker for The ratio of input value and the max value. If the ratio reach a threshold, `Messenger` will send message to somewhere. To test the correctness of logic in `LimitTracker` in a local environment, we can mock a `Messenger` instance. 
```rust
pub trait Messenger {
    fn send(&self, msg: &str);
}

pub struct LimitTracker<'a, T: Messenger> {
    messenger: &'a T,
    value: usize,
    max: usize,
}

impl<'a, T> LimitTracker<'a, T>
where
    T: Messenger,
{
    pub fn new(messenger: &'a T, max: usize) -> LimitTracker<'a, T> {
        LimitTracker {
            messenger,
            value: 0,
            max,
        }
    }

    pub fn set_value(&mut self, value: usize) {
        self.value = value;

        let percentage_of_max = self.value as f64 / self.max as f64;

        if percentage_of_max >= 1.0 {
            self.messenger.send("Error: You are over your quota!");
        } else if percentage_of_max >= 0.9 {
            self.messenger
                .send("Urgent warning: You've used up over 90% of your quota!");
        } else if percentage_of_max >= 0.75 {
            self.messenger
                .send("Warning: You've used up over 75% of your quota!");
        }
    }
}
```

The `MockMessenger` contains a vector for storing the messages to be sent.
And invoking `send` means pushing a new message into `sent_messages`. 

However rust prevent the implementation. Because the `send` is defined as `fn send(&self, msg: &str);`. `self` is immutable, thus, we cannot modify the member `sent_messages` in `self`. In this case, the vector can be wrapped into a `RefCell`, and use `borrow_mut` and `borrow` to access the vector. 

The `borrow` method returns the smart pointer type `Ref<T>`, and `borrow_mut` returns the smart pointer type `RefMut<T>`. Both types implement `Deref`, so we can treat them like regular references.

```rust
struct MockMessenger {
    // sent_messages: Vec<String>,
    sent_messages: RefCell<Vec<String>>,
}

impl MockMessenger {
    fn new() -> MockMessenger {
        MockMessenger {
            sent_messages: RefCell::new(vec![]),
        }
    }
}
impl Messenger for MockMessenger {
    fn send(&self, message: &str) {
        //self.sent_messages.push(String::from(message));
        self.sent_messages.borrow_mut().push(String::from(message));
    }
}

 #[test]
fn it_sends_an_over_75_percent_warning_message() {
    let mock_messenger = MockMessenger::new();
    let mut limit_tracker = LimitTracker::new(&mock_messenger, 100);

    limit_tracker.set_value(80);

    // assert_eq!(mock_messenger.sent_messages.len(), 1);
    assert_eq!(mock_messenger.sent_messages.borrow().len(), 1);
}
```

# Having Multiple Owners of Mutable Data by Combining Rc<T> and RefCell<T>

A common way to use `RefCell<T> `is in combination with `Rc<T>`. Recall that `Rc<T>` lets you have multiple owners of some data, but it only gives immutable access to that data. If you have an `Rc<T>` that holds a `RefCell<T>`, you can get a value that can have multiple owners and that you can mutate.



```rust
use crate::List::{Cons, Nil};
use std::cell::RefCell;
use std::rc::Rc;

#[derive(Debug)]
enum List {
    Cons(Rc<RefCell<i32>>, Rc<List>),
    Nil,
}

fn main() {
    let value = Rc::new(RefCell::new(5));

    let a = Rc::new(Cons(Rc::clone(&value), Rc::new(Nil)));

    let b = Cons(Rc::new(RefCell::new(3)), Rc::clone(&a));
    let c = Cons(Rc::new(RefCell::new(4)), Rc::clone(&a));

    *value.borrow_mut() += 10;

    println!("a after = {:?}", a);
    println!("b after = {:?}", b);
    println!("c after = {:?}", c);
}
/*
a after = Cons(RefCell { value: 15 }, Nil)
b after = Cons(RefCell { value: 3 }, Cons(RefCell { value: 15 }, Nil))
c after = Cons(RefCell { value: 4 }, Cons(RefCell { value: 15 }, Nil))
*/
```

# Memory leak and `Weak<T>`

In Rust, it’s possible to create references where items refer to each other in a cycle. This creates memory leaks because the reference count of each item in the cycle will never reach 0, and the values will never be dropped.

This is an example of reference cycle:

```rust
use crate::List::{Cons, Nil};
use std::cell::RefCell;
use std::rc::Rc;

#[derive(Debug)]
enum List {
    Cons(i32, RefCell<Rc<List>>),
    Nil,
}

impl List {
    fn tail(&self) -> Option<&RefCell<Rc<List>>> {
        match self {
            Cons(_, item) => Some(item),
            Nil => None,
        }
    }
}

fn main() {
    let a = Rc::new(Cons(5, RefCell::new(Rc::new(Nil))));

    println!("a initial rc count = {}", Rc::strong_count(&a));
    println!("a next item = {:?}", a.tail());

    let b = Rc::new(Cons(10, RefCell::new(Rc::clone(&a))));

    println!("a rc count after b creation = {}", Rc::strong_count(&a));
    println!("b initial rc count = {}", Rc::strong_count(&b));
    println!("b next item = {:?}", b.tail());

    if let Some(link) = a.tail() {
        *link.borrow_mut() = Rc::clone(&b);
    }

    println!("b rc count after changing a = {}", Rc::strong_count(&b));
    println!("a rc count after changing a = {}", Rc::strong_count(&a));

/* output:
    a initial rc count = 1
    a next item = Some(RefCell { value: Nil })
    a rc count after b creation = 2
    b initial rc count = 1
    b next item = Some(RefCell { value: Cons(5, RefCell { value: Nil }) })
    b rc count after changing a = 2
    a rc count after changing a = 2
*/
}
```

## Weak Reference

You can create a weak reference to the value within an `Rc<T>` instance by calling `Rc::downgrade` and passing a reference to the `Rc<T>`. Weak references don’t express an ownership relationship, and their count doesn’t affect when an `Rc<T>` instance is cleaned up. They won’t cause a reference cycle because any cycle involving some weak references will be broken once the strong reference count of values involved is 0.

Because the value that `Weak<T>` references might have been dropped, to do anything with the value that a `Weak<T>` is pointing to, you must make sure the value still exists. Do this by calling the upgrade method on a `Weak<T>`instance, which will return an `Option<Rc<T>>`. You’ll get a result of Some if the `Rc<T>` value has not been dropped yet and a result of None if the `Rc<T>` value has been dropped. Because upgrade returns an `Option<Rc<T>>`, Rust will ensure that the Some case and the None case are handled, and there won’t be an invalid pointer.

This is an example of weak reference usage. In this example we will create a tree. 

We want a Node to own its children, and we want to share that ownership with variables so we can access each Node in the tree directly. To do this, we define the `Vec<T>` items to be values of type `Rc<Node>`. We also want to modify which nodes are children of another node, so we have a `RefCell<T> `in children around the `Vec<Rc<Node>>`.

To make the child node aware of its parent, we need to add a parent field to our Node struct definition. We know it can’t contain an `Rc<T>`, because that would create a reference cycle with leaf.parent pointing to branch and branch.children pointing to leaf, which would cause their strong_count values to never be 0.

Thinking about the relationships another way, a parent node should own its children: if a parent node is dropped, its child nodes should be dropped as well. However, a child should not own its parent: if we drop a child node, the parent should still exist.

This is a case for weak references!

In this code, We use the `borrow_mut` method on the `RefCell<Weak<Node>>` in the parent field of leaf, and then we use the `Rc::downgrade` function to create a `Weak<Node>` reference to branch from the `Rc<Node>` in branch.


```rust
use std::cell::RefCell;
use std::rc::{Rc, Weak};

#[derive(Debug)]
struct Node {
    value: i32,
    parent: RefCell<Weak<Node>>,
    children: RefCell<Vec<Rc<Node>>>,
}

fn main() {
    let leaf = Rc::new(Node {
        value: 3,
        parent: RefCell::new(Weak::new()),
        children: RefCell::new(vec![]),
    });

    println!("leaf parent = {:?}", leaf.parent.borrow().upgrade());

    let branch = Rc::new(Node {
        value: 5,
        parent: RefCell::new(Weak::new()),
        children: RefCell::new(vec![Rc::clone(&leaf)]),
    });

    *leaf.parent.borrow_mut() = Rc::downgrade(&branch);

    // If we use Option<Rc<Node>> in parent, it will keep printing infinitely
    println!("leaf parent = {:?}", leaf.parent.borrow().upgrade());
}
```

And the following code uses use `Option<Rc<Node>>` instead of `<Weak<Node>`, leading to memory leak and infinite printing.

```rust
std::cell::RefCell;
use std::rc::{Rc};

#[derive(Debug)]
struct Node {
    value: i32,
    parent: RefCell<Option<Rc<Node>>>,
    children: RefCell<Vec<Rc<Node>>>,
}

fn main() {
    let leaf = Rc::new(Node {
        value: 3,
        parent: RefCell::new(None),
        children: RefCell::new(vec![]),
    });

    println!("leaf parent = {:?}", leaf.parent.borrow());

    let branch = Rc::new(Node {
        value: 5,
        parent: RefCell::new(None),
        children: RefCell::new(vec![Rc::clone(&leaf)]),
    });

    *leaf.parent.borrow_mut() = Some(Rc::clone(&branch));

    println!("leaf parent = {:?}", leaf.parent.borrow());
} 
```

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