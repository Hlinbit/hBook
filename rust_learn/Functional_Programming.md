# Closure in Rust

In Rust, closures are functions that can capture their surrounding environment. They can be understood as callable objects that can be used anywhere a function is required.

## Basic Closure Definition

This is a simple example of closures in Rust. The closure captures variable `x`, and caculate the sum of `a`, `b` and `x`. Variable `a` and `b` can be regarded as the inputs of closure `add`. In this example `add` is of type `Fn(i32, i32) -> i32`.

```
let x = 1;
let add = |a, b| a + b + x;
println!("{}", add(2,3));
```

## Closure Type Inference and Annotation


Closures don’t usually require you to annotate the types of the parameters or the return value like fn functions do. Type annotations are required on functions because the types are part of an explicit interface exposed to your users. 

Closures are typically short and relevant only within a narrow context rather than in any arbitrary scenario. Within these limited contexts, the compiler can infer the types of the parameters and the return type, similar to how it’s able to infer the types of most variables.

These are all valid definitions that will produce the same behavior when they’re called. 

```rust
fn  add_one_v1   (x: u32) -> u32 { x + 1 }
let add_one_v2 = |x: u32| -> u32 { x + 1 };
let add_one_v3 = |x|             { x + 1 };
let add_one_v4 = |x|               x + 1  ;
```

Pay attention to the last line. Because there are no type annotations, we can call the closure with any type. Once a closure is inferred to be of a certain type, it must be used according to that type thereafter.

## Capturing References or Moving Ownership

Closures can capture values from their environment in three ways, which directly map to the three ways a function can take a parameter: borrowing immutably, borrowing mutably, and taking ownership.

This is an example for immutable reference:
```rust
fn main() {
    let list = vec![1, 2, 3];
    println!("Before defining closure: {:?}", list);

    let only_borrows = || println!("From closure: {:?}", list);

    println!("Before calling closure: {:?}", list);
    only_borrows();
    println!("After calling closure: {:?}", list);
}
```

This is an example for mutable reference:
```rust
fn main() {
    let mut list = vec![1, 2, 3];
    println!("Before defining closure: {:?}", list);

    let mut borrows_mutably = || list.push(4);
    
    // This line borrow an immutable reference to println.
    // Howerver we have borrow a mutable reference to borrows_mutably.
    // Rust forbiden there is any reference when a mutable reference exists.

    // println!("Before calling closure: {:?}", list);
    borrows_mutably();
    println!("After calling closure: {:?}", list);
}
```

If you want to force the closure to take ownership of the values it uses in the environment even though the body of the closure doesn’t strictly need ownership, you can use the move keyword before the parameter list.

This technique is mostly useful when passing a closure to a new thread to move the data so that it’s owned by the new thread.

```rust
use std::thread;

fn main() {
    let list = vec![1, 2, 3];
    println!("Before defining closure: {:?}", list);

    thread::spawn(move || println!("From thread: {:?}", list))
        .join()
        .unwrap();
}
```

The reason to move the ownership of list from main thread to new thread is that the new thread might finish before the rest of the main thread finishes, or the main thread might finish first. If the main thread maintained ownership of list but ended before the new thread did and dropped list, the immutable reference in the thread would be invalid. Therefore, the compiler requires that list be moved into the closure given to the new thread so the reference will be valid.

## Use Closure for Iterator

The iterator pattern allows you to perform some task on a sequence of items in turn. An iterator is responsible for the logic of iterating over each item and determining when the sequence has finished. When you use iterators, you don’t have to reimplement that logic yourself.

### The Iterator Trait and the next Method

All iterators implement a trait named Iterator that is defined in the standard library. The definition of the trait looks like this:

```rust
pub trait Iterator {
    type Item;

    fn next(&mut self) -> Option<Self::Item>;

    // methods with default implementations elided
}
```

This code says implementing the `Iterator` trait requires that you also define an Item type, and this Item type is used in the return type of the next method. In other words, the `Item` type will be the type returned from the iterator.

### Methods that Consume the Iterator

The `Iterator` trait has a number of different methods with default implementations provided by the standard library; you can find out about these methods by looking in the standard library API documentation for the `Iterator` trait. Some of these methods call the next method in their definition, which is why you’re required to implement the next method when implementing the `Iterator` trait.

Methods that call `next` are called consuming adaptors, because calling them uses up the iterator. 

One example is the `sum` method, which takes ownership of the iterator and iterates through the items by repeatedly calling next, thus consuming the iterator. 

```rust
#[test]
fn iterator_sum() {
    let v1 = vec![1, 2, 3];

    let v1_iter = v1.iter();

    let total: i32 = v1_iter.sum();

    assert_eq!(total, 6);
}
```
### Methods that Produce Other Iterators

`Iterator` adaptors are methods defined on the `Iterator` trait that don’t consume the iterator. Instead, they produce different iterators by changing some aspect of the original iterator.

The iterator adaptor method `map`, which takes a closure to call on each item as the items are iterated through. The `map` method returns a new iterator that produces the modified items. 

```rust
let v1: Vec<i32> = vec![1, 2, 3];

let v2: Vec<_> = v1.iter().map(|x| x + 1).collect();

assert_eq!(v2, vec![2, 3, 4]);
```

This `collect` consumes the iterator and collects the resulting values into a collection data type.

### Some examples for iterator

Using closures in combination with iterators of containers can achieve the effect of traversing the entire container, which allows us to write more concise and elegant code.

This is an example:

```rust
let numbers = vec![1,3,4,5,6];
let squares: Vec<_> = numbers.iter().map(|x| x * x).collect();
println!("{:?}", squares);
```
The `map` definition is as following:
```rust
fn map<B, F>(self, f: F) -> Map<Self, F>
where
    Self: Sized,
    F: FnMut(Self::Item) -> B,
{
    Map::new(self, f)
}
```
It takes a variable with type `FnMut(Self::Item) -> B`. Here, `Self::Item` refers to the type of element produced by the iterator that the map method is being called on. And `B` is inferred by rust compiler. If the closure return a variable with type `String`, `B` is `String`. In this example, `B` is `i32`.

The closure `|x| x * x` is the input of `map()`. The closure is invoked in `map()` with each element in the `Vec` serving as input. The result `squares` is a new `Vec`, containing the square of each element.

# Use closure as a function input

In many scenarios, we need to pass a function as an argument to another function. Rust provides good support for this usage pattern.

This is two examples for `FnOnce`:
```rust
fn apply<F>(f: F) where F: FnOnce() {
    f();
}

fn main() {
    let count = 0;
    let print_count = || {
        println!("Count: {}", count);
    };

    apply(&print_count);
}
```

```rust
fn apply_once<F>(f: F) where F: FnOnce() {
    f();
}

fn main() {
    let mut message = "Hello".to_string();
    let change_message = || {
        message.push_str(", world!");
    };

    apply_once(change_message);

    println!("{}", message); // 输出 "Hello, world!"
}
```

`FnOnce` can only be invoked once in `apply`. It has the flexibility to either modify the variable in the environment or not.

This is an example for `Fn`:
```rust
fn apply<F>(f: F) where F: Fn() {
    f();
    f();
    f();
}

fn main() {
    let count = 0;
    let print_count = || {
        println!("Count: {}", count);
    };

    apply(&print_count);
}
```
The difference between `Fn` and `FnOnce` is that We can call or not call a closure of type `Fn`, but we cannot do the same with a closure of type `FnOnce`. And `Fn` cannot modify the value of any variable in the environment.

This is an example for `FnMut`:

```rust
fn apply<F>(mut f: F) where F: FnMut() {
    f();
}

fn main() {
    let mut count = 0;
    let mut increment = || {
        count += 1;
    };

    apply(&mut increment);
    apply(&mut increment);
    apply(&mut increment);

    println!("Count: {}", count); // Output "Count: 3"
}
```

The distinction between `FnMut` and `Fn` is that `FnMut` is capable of modifying the captured variable's value within the environment, whereas `Fn` cannot. And `FnMut` can be called 0 or multiple times.