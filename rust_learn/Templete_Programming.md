#  Generic Types, Traits, and Lifetimes

## Generic Data Types

We use generics to create definitions for items like function signatures or structs, which we can then use with many different concrete data types. 

### In Function Definitions

When defining a function that uses generics, we place the generics in the signature of the function where we would usually specify the data types of the parameters and return value. Doing so makes our code more flexible and provides more functionality to callers of our function while preventing code duplication.

To parameterize the types in a new single function, we need to name the type parameter, just as we do for the value parameters to a function. 



### In Struct Definitions


```rust
struct Point<T, U> {
    x: T,
    y: U,
}

fn main() {
    let both_integer = Point { x: 5, y: 10 };
    let both_float = Point { x: 1.0, y: 4.0 };
    let integer_and_float = Point { x: 5, y: 4.0 };
}
```

### In Enum Definitions

```rust
enum Option<T> {
    Some(T),
    None,
}
```

```rust
enum Result<T, E> {
    Ok(T),
    Err(E),
}
```

### In Method Definitions

```rust
struct Point<T> {
    x: T,
    y: T,
}

impl<T> Point<T> {
    fn x(&self) -> &T {
        &self.x
    }
}

fn main() {
    let p = Point { x: 5, y: 10 };

    println!("p.x = {}", p.x());
}
```

By declaring `T` as a generic type after `impl`, Rust can identify that the type in the angle brackets in Point is a generic type rather than a concrete type. Methods written within an `impl` that declares the generic type will be defined on any instance of the type, no matter what concrete type ends up substituting for the generic type.

The following method `distance_from_origin` only defined for `Point<f32>`, rather than any other concrete type.

```rust
impl Point<f32> {
    fn distance_from_origin(&self) -> f32 {
        (self.x.powi(2) + self.y.powi(2)).sqrt()
    }
}
```

Generic type parameters in a struct definition aren’t always the same as those you use in that same struct’s method signatures. 

```rust
struct Point<X1, Y1> {
    x: X1,
    y: Y1,
}

impl<X1, Y1> Point<X1, Y1> {
    fn mixup<X2, Y2>(self, other: Point<X2, Y2>) -> Point<X1, Y2> {
        Point {
            x: self.x,
            y: other.y,
        }
    }
}

fn main() {
    let p1 = Point { x: 5, y: 10.4 };
    let p2 = Point { x: "Hello", y: 'c' };

    let p3 = p1.mixup(p2);

    println!("p3.x = {}, p3.y = {}", p3.x, p3.y);
}
```

The purpose of this example is to demonstrate a situation in which some generic parameters are declared with impl and some are declared with the method definition. Here, the generic parameters X1 and Y1 are declared after impl because they go with the struct definition. The generic parameters X2 and Y2 are declared after fn mixup, because they’re only relevant to the method.

## Performance of Code Using Generics

The good news is that using generic types won't make your program run any slower than it would with concrete types.

Rust accomplishes this by performing monomorphization of the code using generics at compile time. Monomorphization is the process of turning generic code into specific code by filling in the concrete types that are used when compiled. 

The compiler looks at all the places where generic code is called and generates code for the concrete types the generic code is called with.


Let’s look at how this works by using the standard library’s generic `Option<T>` enum:

```rust
let integer = Some(5);
let float = Some(5.0);
```

When Rust compiles this code, it performs monomorphization. During that process, the compiler reads the values that have been used in Option<T> instances and identifies two kinds of Option<T>: one is i32 and the other is f64. As such, it expands the generic definition of Option<T> into two definitions specialized to i32 and f64, thereby replacing the generic definition with the specific ones.

The monomorphized version of the code looks similar to the following:
```rust
enum Option_i32 {
    Some(i32),
    None,
}

enum Option_f64 {
    Some(f64),
    None,
}

fn main() {
    let integer = Option_i32::Some(5);
    let float = Option_f64::Some(5.0);
}
```

## Traits: Defining Shared Behavior

A trait defines functionality a particular type has and can share with other types. We can use traits to define shared behavior in an abstract way. We can use trait bounds to specify that a generic type can be any type that has certain behavior.

Traits are similar to a feature often called interfaces in other languages, although with some differences.