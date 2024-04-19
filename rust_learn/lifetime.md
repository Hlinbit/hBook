# Lifetime 

Lifetimes ensure that references are valid as long as we need them to be. The main aim of lifetimes is to prevent dangling references, which cause a program to reference data other than the data it’s intended to reference.

## Preventing Dangling References with Lifetimes

This code won’t compile because what the value r is referring to has gone out of scope before we try to use it.

```rust
fn main() {
    let r;
    {
        let x = 5;
        r = &x;
    }
    println!("r: {}", r);
}
```


The Rust compiler has a borrow checker that compares scopes to determine whether all borrows are valid.

Here, we’ve annotated the lifetime of r with `'a` and the lifetime of x with `'b`. As you can see, the inner `'b` block is much smaller than the outer `'a` lifetime block. At compile time, Rust compares the size of the two lifetimes and sees that r has a lifetime of `'a` but that it refers to memory with a lifetime of `'b`. The program is rejected because `'b` is shorter than `'a`: the subject of the reference doesn’t live as long as the reference.

```rust
fn main() {
    let r;                // ---------+-- 'a
                          //          |
    {                     //          |
        let x = 5;        // -+-- 'b  |
        r = &x;           //  |       |
    }                     // -+       |
                          //          |
    println!("r: {}", r); //          |
}                         // ---------+

```

## Lifetime Annotation Syntax

Lifetime annotations don’t change how long any of the references live. Rather, they describe the relationships of the lifetimes of multiple references to each other without affecting the lifetimes. 

Examples:

```rust 
&i32        // a reference
&'a i32     // a reference with an explicit lifetime
&'a mut i32 // a mutable reference with an explicit lifetime
```

## Lifetime Annotations in Function Signatures


The generic lifetime `'a` will get the concrete lifetime that is equal to the smaller of the lifetimes of x and y. Because we’ve annotated the returned reference with the same lifetime parameter `'a`, the returned reference will also be valid for the length of the smaller of the lifetimes of x and y.


```rust
fn longest<'a>(x: &'a str, y: &'a str) -> &'a str  {
    if x.len() > y.len() {
        x
    } else {
        y
    }
}

fn main() {
    let string1 = String::from("abcd");
    let string2 = "xyz";

    let result = longest(string1.as_str(), string2);
    println!("The longest string is {}", result);
}
```

## Lifetime Annotations in Struct Definitions

So far, the structs we’ve defined all hold owned types. We can define structs to hold references, but in that case we would need to add a lifetime annotation on every reference in the struct’s definition.

This annotation means an instance of ImportantExcerpt can’t outlive the reference it holds in its part field.

```rust
struct ImportantExcerpt<'a> {
    part: &'a str,
}

fn main() {
    let novel = String::from("Call me Ishmael. Some years ago...");
    let first_sentence = novel.split('.').next().expect("Could not find a '.'");
    let i = ImportantExcerpt {
        part: first_sentence,
    };
}
```