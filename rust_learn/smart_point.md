# Box

## What is Box

Boxes allow you to store data on the heap rather than the stack. What remains on the stack is the pointer to the heap data. 

You’ll use them most often in these situations:

- When you have a type whose size can’t be known at compile time and you want to use a value of that type in a context that requires an exact size
- When you have a large amount of data and you want to transfer ownership but ensure the data won’t be copied when you do so
- When you want to own a value and you care only that it’s a type that implements a particular trait rather than being of a specific type

## How to create and use a Box

```
fn main() {
    let b = Box::new(5);
    println!("b = {}", b);
}
```

## mut Box and Box

`Box<T>`: This is a box that owns its data and allows read access to the data it points to. You cannot modify the data inside a `Box<T>` unless the data itself has internal mutability (e.g., using `Cell<T>` or `RefCell<T>`).

`mut Box<T>`: This is a mutable box that not only owns its data but also allows you to modify the data it points to directly. 

```rust
fn main() {
    let mut boxx = Box::new(10);
    println!("Original value: {}", boxx);

    // Modify the value inside the box
    *boxx = 20;
    println!("Modified value: {}", boxx);
}
```

## Use Scenario

### Unknown Compile Size

`List` has an undetermined length at compile time.

```rust
enum List {
    Cons(i32, Box<List>),
    Nil,
}

use crate::List::{Cons, Nil};

fn main() {
    let list = Cons(1, Box::new(Cons(2, Box::new(Cons(3, Box::new(Nil))))));
}
```

### Avoid Copy

```rust
#[derive(Clone, Debug)]
struct LargeData {
    data: [u8; 1024 * 1024], // 1 MB of data
}

impl Copy for LargeData {}

fn process_raw_data(data: LargeData) {
    println!("processing {} ...", data.len());
}

fn process_box_data(data: Box<LargeData>) {
    println!("processing {} ...", data.len());
}

fn main() {
    let large_data = LargeData {
        data: [0; 1024 * 1024], // Initialize with zeros
    };

    process_raw_data(large_data);
    process_box_data(Box::<LargeData>::new(large_data));
    println!("Data copied successfully!");
}
```

### Dynamic Trait Objects

In Rust, regular references must have a specific static type. ` &dyn Trait ` and  `Box<dyn Trait>` are Ok for trait object.

```rust
trait Speak {
    fn speak(&self);
}

struct Dog;
struct Cat;

impl Speak for Dog {
    fn speak(&self) {
        println!("www！");
    }
}

impl Speak for Cat {
    fn speak(&self) {
        println!("mmm！");
    }
}

fn make_some_noise(animal: Box<dyn Speak>) {
    animal.speak();
}

fn main() {
    let dog = Box::new(Dog);
    let cat = Box::new(Cat);

    make_some_noise(dog);
    make_some_noise(cat);
}
```

# Rc

## What is Rc
In the majority of cases, ownership is clear: you know exactly which variable owns a given value. 

However, there are cases when a single value might have multiple owners. 

For example, in graph data structures, multiple edges might point to the same node, and that node is conceptually owned by all of the edges that point to it. A node shouldn’t be cleaned up unless it doesn’t have any edges pointing to it and so has no owners.

## How to create and use a Rc

```rust
use std::rc::Rc;

fn main() {
    let rc = Rc::new(5);
    let rc_clone = Rc::clone(&rc);

    println!("Original Rc: {}", rc);
    println!("Cloned Rc: {}", rc_clone);
}
```


## Use Scenario

# RefCell

## What is RefCell

Interior mutability is a design pattern in Rust that allows you to mutate data even when there are immutable references to that data; normally, this action is disallowed by the borrowing rules. 