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