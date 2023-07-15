# Thread

## How to create a thread 

Programming languages implement threads in a few different ways, and many operating systems provide an API the language can call for creating new threads. The Rust standard library uses a 1:1 model of thread implementation, whereby a program uses one operating system thread per one language thread. There are crates that implement other models of threading that make different tradeoffs to the 1:1 model.

To create a new thread, we call the `thread::spawn` function and pass it a closure containing the code we want to run in the new thread. The following example prints some text from a main thread and other text from a new thread:

```rust
use std::thread;
use std::time::Duration;

fn main() {
    let handle = thread::spawn(|| {
        for i in 1..10 {
            println!("hi number {} from the spawned thread!", i);
            thread::sleep(Duration::from_millis(1));
        }
    });

    for i in 1..5 {
        println!("hi number {} from the main thread!", i);
        thread::sleep(Duration::from_millis(1));
    }

    handle.join().unwrap();
}
```

This example shows some key functions about thread in Rust. 

In the code, the return value of `thread::spawn` is saved in a variable. The return type of `thread::spawn` is `JoinHandle`. A `JoinHandle` is an owned value that, when we call the join method on it, will wait for its thread to finish. The code shows how to use the `JoinHandle` of the thread we created and call `join `to make sure the spawned thread finishes before main exits.

Calling `join` on the handle blocks the thread currently running until the thread represented by the handle terminates. 

## Threads communication 

### `move` Semantics
We'll often use the move keyword with closures passed to thread::spawn because the closure will then take ownership of the values it uses from the environment, thus transferring ownership of those values from one thread to another.

This is an example about how to transfer a vector from main thread to sub thread. 

By adding the `move` keyword before the closure, we force the closure to take ownership of the values it’s using rather than allowing Rust to infer that it should borrow the values. By telling Rust to move ownership of v to the spawned thread, we’re guaranteeing Rust that the main thread won’t use v anymore. 

```rust
use std::thread;

fn main() {
    let v = vec![1, 2, 3];

    let handle = thread::spawn(move || {
        println!("Here's a vector: {:?}", v);
    });
    // This will lead to a compiler error.
    // drop(v);

    handle.join().unwrap();
}
```

### Messages Passing

One increasingly popular approach to ensuring safe concurrency is message passing, where threads or actors communicate by sending each other messages containing data.

To accomplish message-sending concurrency, Rust's standard library provides an implementation of channels. A channel is a general programming concept by which data is sent from one thread to another.

```rust
use std::sync::mpsc;
use std::thread;

fn main() {
    let (tx, rx) = mpsc::channel();

   
    thread::spawn(move || {
        let val = String::from("hi");
        tx.send(val).unwrap();
        // Using the value has been sent will cause compiler error.
        // println!("val is {}", val);
    });


    let received = rx.recv().unwrap();
    println!("Got: {}", received);
}
```

The send function takes ownership of its parameter, and when the value is moved, the receiver takes ownership of it. This stops us from accidentally using the value again after sending it; the ownership system checks that everything is okay.

#### Sending Multiple Values and Seeing the Receiver Waiting

In the following example, the spawned thread has a vector of strings that we want to send to the main thread. We iterate over them, sending each individually, and pause between each by calling the thread::sleep function with a Duration value of 1 second.

```rust
use std::sync::mpsc;
use std::thread;
use std::time::Duration;

fn main() {
    let (tx, rx) = mpsc::channel();

    thread::spawn(move || {
        let vals = vec![
            String::from("hi"),
            String::from("from"),
            String::from("the"),
            String::from("thread"),
        ];

        for val in vals {
            tx.send(val).unwrap();
            thread::sleep(Duration::from_secs(1));
        }
    });

    for received in rx {
        println!("Got: {}", received);
    }
}
/*
Got: hi
Got: from
Got: the
Got: thread
*/
```

In the main thread, we’re not calling the `recv` function explicitly anymore: instead, we’re treating rx as an iterator. For each value received, we’re printing it. When the channel is closed, iteration will end.


#### Creating Multiple Producers by Cloning the Transmitter

Through calling clone on the transmitter, new transmitters is created and we can pass them to the spawned threads. 

```rust
use std::sync::mpsc;
use std::thread;

fn main() {
    let (tx, rx) = mpsc::channel();
    for _ in 0..10 {
        let tx_tmp = tx.clone();
        thread::spawn(move || {
            let val = String::from("hi");
            tx_tmp.send(val).unwrap();
        });
    }
    // Drop is required, since the existence of tx will cause rx keeping waiting for messages. And the process will never end.
    drop(tx);
    for msg in rx {
        println!("Got: {}", msg);
    }
}
```


### Shared-State Concurrency

In a way, channels in any programming language are similar to single ownership, because once you transfer a value down a channel, you should no longer use that value. Shared memory concurrency is like multiple ownership: multiple threads can access the same memory location at the same time.

#### Mutex<T>

In rust `Mutex<T>` allow access to data from one thread at a time. However, if you want to share a `Mutex<T>` between multiple threads, you must wrap it into `Arc`.

The example demonstrates the necessity of doing so.

Based on intuition, we might write code like this. In the code, we create multiple threads to modify the value of a `Mutex<i32>` variable.

However, the move semantics would cause the first created thread to take ownership of the counter, resulting in a compilation error. Therefore, we came up with the idea of using `Rc` to wrap the counter and cloning multiple `Mutex<T>` instances to allow multiple threads to share ownership.


```rust
use std::sync::Mutex;
use std::thread;

fn main() {
    let counter = Mutex::new(0);
    let mut handles = vec![];

    for _ in 0..10 {
        let handle = thread::spawn(move || {
            let mut num = counter.lock().unwrap();

            *num += 1;
        });
        handles.push(handle);
    }

    for handle in handles {
        handle.join().unwrap();
    }

    println!("Result: {}", *counter.lock().unwrap());
}
```

However, `Rc<T>` is not thread-safe, so the Rust compiler prohibits the use of `Rc` in multi-threaded scenarios. The correct approach is to use `Arc` to achieve shared ownership among multiple threads. The a stands for atomic, meaning it’s an atomically reference counted type. 

```rust
use std::sync::{Mutex, Arc};
use std::thread;

fn main() {
    let counter = Arc::new(Mutex::new(0));
    let mut handles = vec![];

    for _ in 0..10 {
        let tmp_counter = counter.clone();
        let handle = thread::spawn(move ||{
            let mut num = tmp_counter.lock().unwrap();

            *num += 1;
        });
        handles.push(handle)
    }

    for handle in handles {
        handle.join().unwrap();
    }

    println!("Result: {}", *counter.lock().unwrap());
}
```

Note that if you are doing simple numerical operations, there are types simpler than `Mutex<T>` types provided by the `std::sync::atomic` module of the standard library. These types provide safe, concurrent, atomic access to primitive types.

# Extensible Concurrency with the Sync and Send Traits

The `Send` marker trait indicates that ownership of values of the type implementing Send can be transferred between threads. Almost every Rust type is `Send`, but there are some exceptions, including `Rc<T>`.
