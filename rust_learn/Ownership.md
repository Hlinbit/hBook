# Ownership in rust


In Rust, ownership is a fundamental concept that governs how memory is managed and shared. The ownership model in Rust provides a set of rules that determine how values are owned, borrowed, and accessed. It ensures memory safety without the need for garbage collection or manual memory management.

The ownership model in Rust consists of the following key principles:

Ownership: Each value in Rust has a unique owner, which is the variable that holds the value. There can only be one owner at a time, and the owner is responsible for releasing the memory when it goes out of scope.

Move Semantics: When a value is assigned to another variable or passed as a function argument, its ownership is moved from the source variable to the destination variable. This transfer of ownership ensures that there is always only one valid owner of a value at any given time, preventing issues like use-after-free and double-free errors.

Borrowing: Rather than transferring ownership, Rust allows borrowing a reference to a value. Borrowing allows temporary access to a value without taking ownership. Borrowed references can be either immutable (&T) or mutable (&mut T), and they come with strict rules regarding their scope and lifetime.

Lifetimes: Lifetimes are used to track the validity of references and prevent dangling references. Lifetimes specify how long a borrowed reference is valid and ensure that references do not outlive the values they refer to.

By enforcing these ownership rules at compile time, Rust's ownership model enables memory safety and eliminates common programming errors, such as null pointer dereferences, data races, and memory leaks.

## Ownership Principle and Move Semantics

In this example, the ownership of the string "Hello" has been transferred to `s2` because of the assignment `s2 = s1`

When working with types that do not implement the `Copy` trait in Rust, the language employs move semantics to transfer ownership when using the `= `operator.

In Rust, types that implement the Copy trait have copy semantics rather than move semantics. As a result, direct semantic transfer, similar to C++'s std::move(), cannot be used.

```
fn main() {
    let s1 = String::from("Hello");
    let s2 = s1;
    // Following Code has compile error, since 's1' has lost the ownership of string
    // println!("s1: {}", s1);
    println!("s2: {}", s2);
}
```

## Borrowing and Reference

In this example, input of `calculate_length` is a borrowed reference from `s1`. This allows `calculate_length` to access `s1` without taking ownership of it.

Ownership is a concept for rust compiler. Through the owership, rust compiler can make dicision whether a memory field can be recycled, to prevent the problems, such as null pointer dereferences, data races, and memory leaks.

```
fn calculate_length(s: &String) -> usize {
    s.len()
}

fn main() {
    let s1 = String::from("Hello");
    let len = calculate_length(&s1); 
    println!("Length: {}", len);
}
```

## Lifetime Explaination

In Rust, `'a` represents a lifetime parameter for defining lifetimes. Lifetime parameters are used to specify the validity scope of references, ensuring that references do not outlive the values they refer to.


In this example, `'a` is used to annotate the lifetimes of the function parameters `s1` and `s2`, as well as the lifetime of the function's return value. This way, the lifetime annotations in the function signature indicate that the returned reference is valid within the same scope as the input references. In other words, the returned reference will not outlive the lifetimes of the input references and the values they point to.

```
fn longest<'a>(s1: &'a str, s2: &'a str) -> &'a str {
    if s1.len() > s2.len() {
        s1
    } else {
        s2
    }
}

fn main() {
    let s1 = String::from("Hello");
    let s2 = String::from("World");
    let result = longest(&s1, &s2); 
    println!("Longest: {}", result);
}
```

## Why String not implements `Copy` trait

Because `String` is dynamically allocated and the memory on the heap is managed by a pointer, directly copying the value of a String would result in two `String` instances pointing to the same block of heap memory. This could lead to potential issues such as use-after-move or multiple deallocations of the same memory.