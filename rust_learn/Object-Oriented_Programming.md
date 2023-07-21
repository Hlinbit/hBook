
# The Concept trait

## How to define a trait

In Rust, a trait is a way to define shared behavior across types. It is similar to pure virtual classes in C++. 

The example provided demonstrates the three elements that can be included within a Rust trait: method signatures, constant declarations, and type signatures (or associated types). Any elements in `trait` need to be defined in the implementing struct or enum. Failure to do so will result in a compilation error.


```
trait Shape {
    type Unit;
    const PAI: f64;

    fn area(&self) -> Self::Unit;
}

struct Circle {
    radius: f64,
}


impl Shape for Circle {
    type Unit = f64;
    const PAI: f64 = 3.1415;

    fn area(&self) -> Self::Unit {
        Self::PAI * self.radius * self.radius
    }
}
```

Method Signatures: These define the blueprint of functions that must be implemented in a struct or enum which uses this trait. 

Constant Declarations: This feature allows you to specify constants within your trait. 

Type Signatures (Associated Types): Associated types allow you to introduce a type that is unknown until the trait is implemented. This further adds to the customization potential of traits. 

By effectively utilizing these features, you can create complex and flexible trait definitions, making your Rust code more adaptable and reusable.

## Implementing a Trait on a Type

One restriction to note is that we can implement a trait on a type only if at least one of the trait or the type is local to our crate. We can’t implement external traits on external types.

This restriction is part of a property called coherence, and more specifically the orphan rule, so named because the parent type is not present. This rule ensures that other people’s code can’t break your code and vice versa. Without the rule, two crates could implement the same trait for the same type, and Rust wouldn’t know which implementation to use.

```rust
pub trait Summary {
    fn summarize(&self) -> String;
}

pub struct NewsArticle {
    pub headline: String,
    pub location: String,
    pub author: String,
    pub content: String,
}

impl Summary for NewsArticle {
    fn summarize(&self) -> String {
        format!("{}, by {} ({})", self.headline, self.author, self.location)
    }
}

pub struct Tweet {
    pub username: String,
    pub content: String,
    pub reply: bool,
    pub retweet: bool,
}

impl Summary for Tweet {
    fn summarize(&self) -> String {
        format!("{}: {}", self.username, self.content)
    }
}

use aggregator::{Summary, Tweet};

fn main() {
    let tweet = Tweet {
        username: String::from("horse_ebooks"),
        content: String::from(
            "of course, as you probably already know, people",
        ),
        reply: false,
        retweet: false,
    };

    println!("1 new tweet: {}", tweet.summarize());

    let article = NewsArticle {
        headline: String::from("Daily news"),
        location: String::from(
            "USA",
        ),
        author: String::from("Trump"),
        content: String::from("No evidence"),
    };
    println!("1 new artircal: {}", article.summarize());
}
```


## Default Implementations

Sometimes it’s useful to have default behavior for some or all of the methods in a trait instead of requiring implementations for all methods on every type. Then, as we implement the trait on a particular type, we can keep or override each method’s default behavior.


```rust
pub trait Summary {
    fn summarize(&self) -> String {
        String::from("(Read more...)")
    }
}
```

## Traits as Parameters

Instead of a concrete type for the item parameter, we specify the impl keyword and the trait name. This parameter accepts any type that implements the specified trait. 

```rust
pub fn notify(item: &impl Summary) {
    println!("Breaking news! {}", item.summarize());
}
```

### Trait Bound Syntax

The following statements are examples for using traits as inputs.

```rust

pub fn notify<T: Summary>(item: &T) {
    println!("Breaking news! {}", item.summarize());
}

pub fn notify(item1: &impl Summary, item2: &impl Summary) {}

pub fn notify<T: Summary>(item1: &T, item2: &T) {}

```

### Specifying Multiple Trait Bounds with the + Syntax

We can also specify more than one trait bound. Say we wanted notify to use display formatting as well as `summarize` on item: we specify in the notify definition that item must implement both `Display` and `Summary`. We can do so using the `+` syntax:

```rust
pub fn notify(item: &(impl Summary + Display)) {}
// or 
pub fn notify<T: Summary + Display>(item: &T) {}
```

### Clearer Trait Bounds with where Clauses

Using too many trait bounds has its downsides. Each generic has its own trait bounds, so functions with multiple generic type parameters can contain lots of trait bound information between the function’s name and its parameter list, making the function signature hard to read.

```rust
fn some_function<T: Display + Clone, U: Clone + Debug>(t: &T, u: &U) -> i32 {}
```

Rust has alternate syntax for specifying trait bounds inside a where clause after the function signature. So instead of writing this:

```rust
fn some_function<T, U>(t: &T, u: &U) -> i32
where
    T: Display + Clone,
    U: Clone + Debug,
{}
```

### Returning Types that Implement Traits

We can also use the impl Trait syntax in the return position to return a value of some type that implements a trait, as shown here:

By using `impl Summary` for the return type, we specify that the `returns_summarizable` function returns some type that implements the `Summary` trait without naming the concrete type. In this case, `returns_summarizable` returns a `Tweet`, but the code calling this function doesn’t need to know that.

```rust
fn returns_summarizable() -> impl Summary {
    Tweet {
        username: String::from("horse_ebooks"),
        content: String::from(
            "of course, as you probably already know, people",
        ),
        reply: false,
        retweet: false,
    }
}
```

However, you can only use `impl Trait` if you’re returning a single type. For example, this code that returns either a `NewsArticle` or a `Tweet` with the return type specified as `impl Summary` wouldn’t work:

```rust
fn returns_summarizable(switch: bool) -> impl Summary {
    if switch {
        NewsArticle {
            headline: String::from(
                "Penguins win the Stanley Cup Championship!",
            ),
            location: String::from("Pittsburgh, PA, USA"),
            author: String::from("Iceburgh"),
            content: String::from(
                "The Pittsburgh Penguins once again are the best \
                 hockey team in the NHL.",
            ),
        }
    } else {
        Tweet {
            username: String::from("horse_ebooks"),
            content: String::from(
                "of course, as you probably already know, people",
            ),
            reply: false,
            retweet: false,
        }
    }
}
```

The following code will work:

```rust
fn returns_summarizable(switch: bool) -> Box<dyn Summary> {
    if switch {
        Box::new(NewsArticle {
            headline: String::from(
                "Penguins win the Stanley Cup Championship!",
            ),
            location: String::from("Pittsburgh, PA, USA"),
            author: String::from("Iceburgh"),
            content: String::from(
                "The Pittsburgh Penguins once again are the best \
                 hockey team in the NHL.",
            ),
        })
    } else {
        Box::new(Tweet {
            username: String::from("horse_ebooks"),
            content: String::from(
                "of course, as you probably already know, people",
            ),
            reply: false,
            retweet: false,
        })
    }
}
```


### Using Trait Bounds to Conditionally Implement Methods

By using a trait bound with an impl block that uses generic type parameters, we can implement methods conditionally for types that implement the specified traits. 

For example, `Pair<T>` only implements the `cmp_display` method if its inner type T implements the `PartialOrd` trait that enables comparison and the `Display` trait that enables printing.

```rust
use std::fmt::Display;

struct Pair<T> {
    x: T,
    y: T,
}

impl<T> Pair<T> {
    fn new(x: T, y: T) -> Self {
        Self { x, y }
    }
}

impl<T: Display + PartialOrd> Pair<T> {
    fn cmp_display(&self) {
        if self.x >= self.y {
            println!("The largest member is x = {}", self.x);
        } else {
            println!("The largest member is y = {}", self.y);
        }
    }
}
```

# Polymorphism in rust

Trait objects in Rust support runtime polymorphism. In the example below, we tried to return different types, but all implemented the trait object `Summery`. However, the result failed. This is because the compiler cannot determine the returned object at compile time and cannot generate corresponding concrete execution code.


```rust
fn returns_summarizable(switch: bool) -> impl Summary {
    if switch {
        NewsArticle {
            headline: String::from(
                "Penguins win the Stanley Cup Championship!",
            ),
            location: String::from("Pittsburgh, PA, USA"),
            author: String::from("Iceburgh"),
            content: String::from(
                "The Pittsburgh Penguins once again are the best \
                 hockey team in the NHL.",
            ),
        }
    } else {
        Tweet {
            username: String::from("horse_ebooks"),
            content: String::from(
                "of course, as you probably already know, people",
            ),
            reply: false,
            retweet: false,
        }
    }
}
```
In addition, in the file system, we need to support multiple files that implement the same interface but have completely different types. All of these require runtime polymorphism. For example:

```rust
// A File can be directory, hard link, executable file or text file. But they all implement write and read.
trait File {
    fn write(name: String, buffer: &[u8]);
    fn read(name: String, buffer: &[u8]);
}
```

In this case, we can use dyn with a reference or a smart pointer to inform Rust to perform runtime polymorphic checks instead of generating code for specific types at compile time.

```rust
let x : Vec<Box<dyn File>>;
let y: Vec<&dyn File>;
let z: Vec<Rc<dyn File>>;
```

# Validating References with Lifetimes

Lifetimes are another kind of generic that we’ve already been using. Rather than ensuring that a type has the behavior we want, lifetimes ensure that references are valid as long as we need them to be.

Rust requires us to annotate the relationships using generic lifetime parameters to ensure the actual references used at runtime will definitely be valid.

## Preventing Dangling References with Lifetimes

The main aim of lifetimes is to prevent dangling references, which cause a program to reference data other than the data it’s intended to reference.

```rust
```