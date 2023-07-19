# Collection in rust
Rust’s standard library includes a number of very useful data structures called collections. Most other data types represent one specific value, but collections can contain multiple values. Unlike the built-in array and tuple types, the data these collections point to is stored on the heap, which means the amount of data does not need to be known at compile time and can grow or shrink as the program runs. 


- A vector allows you to store a variable number of values next to each other.
- A string is a collection of characters.
- A hash map allows you to associate a value with a particular key. It’s a particular implementation of the more general data structure called a map.

## Vector

To create a new empty vector, we call the `Vec::new` function. Because we aren’t inserting any values into this vector, Rust doesn’t know what kind of elements we intend to store. We added a type annotation here.

```rust
    let v: Vec<i32> = Vec::new();
```
More often, you’ll create a Vec<T> with initial values and Rust will infer the type of value you want to store, so you rarely need to do this type annotation. 
```rust
    let v = vec![1, 2, 3];
```

## Updating a Vector

To create a vector and then add elements to it, we can use the `push` method. The numbers we place inside are all of type i32, and Rust infers this from the data, so we don’t need the Vec<i32> annotation.

```rust
    let mut v = Vec::new();

    v.push(5);
    v.push(6);
    v.push(7);
    v.push(8);
```
## Reading Elements of Vectors

There are two ways to reference a value stored in a vector: via indexing or using the get method.

When we use the get method with the index passed as an argument, we get an Option<&T> that we can use with match.

```rust
    let v = vec![1, 2, 3, 4, 5];

    let third: &i32 = &v[2];
    println!("The third element is {third}");

    let third: Option<&i32> = v.get(2);
    match third {
        Some(third) => println!("The third element is {third}"),
        None => println!("There is no third element."),
    }
```

A subtle error for vector: 

```rust
    let mut v = vec![1, 2, 3, 4, 5];

    let first = &v[0];

    v.push(6);

    println!("The first element is: {first}");

/* error[E0502]: cannot borrow `v` as mutable because it is also borrowed as immutable */
```

This error is due to the way vectors work: because vectors put the values next to each other in memory, adding a new element onto the end of the vector might require allocating new memory and copying the old elements to the new space, if there isn’t enough room to put all the elements next to each other where the vector is currently stored. In that case, the reference to the first element would be pointing to deallocated memory. The borrowing rules prevent programs from ending up in that situation.

## Iterating over the Values in a Vector

To access each element in a vector in turn, we would iterate through all of the elements rather than use indices to access one at a time. 

```rust
    let v = vec![100, 32, 57];
    for i in &v {
        println!("{i}");
    }
```

We can also iterate over mutable references to each element in a mutable vector in order to make changes to all the elements. 

To change the value that the mutable reference refers to, we have to use the * dereference operator to get to the value in i before we can use the += operator. 

```rust
let mut v = vec![100, 32, 57];
for i in &mut v {
    *i += 50;
}
```

The reference to the vector that the for loop holds prevents simultaneous modification of the whole vector. For example:

```rust
let mut v = vec![100, 32, 57];
for i in &mut v {
    if *i > 50 {
        v.push(50);
    }
    *i += 50;
}
/* error[E0499]: cannot borrow `v` as mutable more than once at a time. */
```

## Using an Enum to Store Multiple Types

Vectors can only store values that are the same type. This can be inconvenient; there are definitely use cases for needing to store a list of items of different types. Fortunately, the variants of an enum are defined under the same enum type, so when we need one type to represent elements of different types, we can define and use an enum.

Using an enum plus a match expression means that Rust will ensure at compile time that every possible case is handled
```rust
enum SpreadsheetCell {
    Int(i32),
    Float(f64),
    Text(String),
}

let row = vec![
    SpreadsheetCell::Int(3),
    SpreadsheetCell::Text(String::from("blue")),
    SpreadsheetCell::Float(10.12),
];
```

## Dropping a Vector Drops Its Elements

When the vector gets dropped, all of its contents are also dropped, meaning the integers it holds will be cleaned up. The borrow checker ensures that any references to contents of a vector are only used while the vector itself is valid.