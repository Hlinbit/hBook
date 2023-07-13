# Ownership in rust

# What is ownership for?

Ownership is a set of rules that govern how a Rust program manages memory. In rust memory is managed through a system of ownership with a set of rules that the compiler checks. If any of the rules are violated, the program won’t compile. None of the features of ownership will slow down your program while it’s running.

## The rules for ownership in rust

First, let’s take a look at the ownership rules: 

- Each value in Rust has an owner.
- There can only be one owner at a time.
- When the owner goes out of scope, the value will be dropped.

The first rule means that we must access a value through a owner, simply speaking, a variable.

The second rule means that, Two variables cannot own the same memory area at the same time without copying the value from a memory field to another memory field.

The third rule means that the memory is automatically returned once the variable that owns it goes out of scope. 

The third rule and the second rule have a mutually dependent relationship. If there is not the second rule, the third rule would lead to the `double-free` problem. The existence of the third rule make the second rule is absolute necessary.


## Variables and Data Interacting with Move

The types like `String`, which doesn't implement trait `Copy`, will trigger `move` semantic. That ensures that `double free` will never appear in rust program. 



## Variables and Data Interacting with Clone

`Clone` is an essential function to deeply copy the heap data, such as `String`.

## Stack-Only Data: Copy

```
let x = 5;
let y = x;

println!("x = {}, y = {}", x, y);
```

The reason is that types such as integers that have a known size at compile time are stored entirely on the stack, so copies of the actual values are quick to make.   There’s no difference between deep and shallow copying here, so calling clone wouldn’t do anything different from the usual shallow copying, and we can leave it out.


## Ownership and Functions

```rust
fn main() {
    let s = String::from("hello");  // s comes into scope

    takes_ownership(s);             // s's value moves into the function...
                                    // ... and so is no longer valid here

    let x = 5;                      // x comes into scope

    makes_copy(x);                  // x would move into the function,
                                    // but i32 is Copy, so it's okay to still
                                    // use x afterward

} // Here, x goes out of scope, then s. But because s's value was moved, nothing
  // special happens.

fn takes_ownership(some_string: String) { // some_string comes into scope
    println!("{}", some_string);
} // Here, some_string goes out of scope and `drop` is called. The backing
  // memory is freed.

fn makes_copy(some_integer: i32) { // some_integer comes into scope
    println!("{}", some_integer);
} // Here, some_integer goes out of scope. Nothing specia
```


## Return Values and Scope

```rust
fn main() {
    let s1 = gives_ownership();         // gives_ownership moves its return
                                        // value into s1
    println!("s1 = {}", s1);

    let s2 = String::from("hello");     // s2 comes into scope
    println!("s2 = {}", s2);

    let s3 = takes_and_gives_back(s2);  // s2 is moved into
                                        // takes_and_gives_back, which also
                                        // moves its return value into s3
    println!("s3 = {}", s3);
} // Here, s3 goes out of scope and is dropped. s2 was moved, so nothing
  // happens. s1 goes out of scope and is dropped.

fn gives_ownership() -> String {             // gives_ownership will move its
                                             // return value into the function
                                             // that calls it

    let some_string = String::from("yours"); // some_string comes into scope

    some_string                              // some_string is returned and
                                             // moves out to the calling
                                             // function
}

// This function takes a String and returns one
fn takes_and_gives_back(a_string: String) -> String { // a_string comes into
                                                      // scope

    a_string  // a_string is returned and moves out to the calling function
}

/*
s1 = yours
s2 = hello
s3 = hello
*/
```

# References and Borrowing

A reference is like a pointer in that it’s an address we can follow to access the data stored at that address; that data is owned by some other variable. 

Unlike a pointer, a reference is guaranteed to point to a valid value of a particular type for the life of that reference.

There are two rules for application of reference:

- At any given time, you can have either one mutable reference or any number of immutable references.
- References must always be valid.

# Reference in function

In this example, The `&s1` syntax lets us create a reference that refers to the value of `s1` but does not own it. Because it does not own it, the value it points to will not be dropped when the reference stops being used.

We call the action of creating a reference borrowing. 

```rust
fn main() {
    let s1 = String::from("hello");

    let len = calculate_length(&s1);

    println!("The length of '{}' is {}.", s1, len);
}

fn calculate_length(s: &String) -> usize {
    s.len()
}
```

## Mutable References

Mutable references have one big restriction: if you have a mutable reference to a value, you can have no other references to that value. This code that attempts to create two mutable references to s will fail. We also cannot have a mutable reference while we have an immutable one to the same value. The following code is an example.

```rust
    let mut s = String::from("hello");

    let r1 = &s; // no problem
    let r2 = &s; // no problem
    let r3 = &mut s; // BIG PROBLEM

    println!("{}, {}, and {}", r1, r2, r3);
```

However, a reference’s scope starts from where it is introduced and continues through the last time that reference is used. Thus, the following example will not cause any error.

```
    let mut s = String::from("hello");

    let r1 = &s; // no problem
    let r2 = &s; // no problem
    println!("{} and {}", r1, r2);
    // variables r1 and r2 will not be used after this point

    let r3 = &mut s; // no problem
    println!("{}", r3);

```

The restriction preventing multiple mutable references to the same data at the same time allows for mutation but in a very controlled fashion. The benefit of having this restriction is that Rust can prevent data races at compile time. A data race is similar to a race condition and happens when these three behaviors occur:

- Two or more pointers access the same data at the same time.
- At least one of the pointers is being used to write to the data.
- There’s no mechanism being used to synchronize access to the data.


```rust
fn main() {
    let mut s = String::from("hello");

    change(&mut s);
}

fn change(some_string: &mut String) {
    some_string.push_str(", world");
}
```

Note that a reference’s scope starts from where it is introduced and continues through the last time that reference is used.


## Dangling References

In this example, the lifetime of `s` is in the function `dangle`. When `dangle` finishes, `s` will be deallocated. Thus, returning a reference to a deallocated variable will cause a dangling pointer error.

```rust
fn dangle() -> &String { // dangle returns a reference to a String

    let s = String::from("hello"); // s is a new String

    &s // we return a reference to the String, s
}
```

The right way is:

```rust
fn no_dangle() -> String {
    let s = String::from("hello");

    s
}
```
Ownership is moved out of the function, and nothing is deallocated.