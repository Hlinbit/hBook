# basic type

## Option


### definition
Option is an enumeration type in the Rust language, and its definition is as follows:

```
enum Option<T> {
    None,
    Some(T),
}
```

It is used to represent a value that may either exist (wrapped in Some) or not exist (None).

### exemple

In this example, we can see that Rust provides a user-friendly way to handle the unexpected result value.

```
fn find_element_index(vec: Vec<i32>, elem: i32) -> Option<usize> {
    for (index, &item) in vec.iter().enumerate() {
        if item == elem {
            return Some(index);
        }
    }
    None
}

fn main() {
    let vec = vec![10, 20, 30, 40, 50];
    match find_element_index(vec, 30) {
        Some(index) => println!("Element found at index {}", index),
        None => println!("Element not found in vec"),
    }
}

```

Another example demonstrates the usage of the specific method `take()` for `Option`. take() returns an `Option` value, and the original value is set to `None`.
```
struct Container {
    value: Option<String>,
}

impl Container {
    fn new() -> Self {
        Container { value: None }
    }
    
    fn set_value(&mut self, value: String) {
        self.value = Some(value);
    }
    
    fn take_value(&mut self) -> Option<String> {
        self.value.take()
    }
}

fn main() {
    let mut container = Container::new();
    container.set_value("Hello, world!".to_string());
    let value = container.take_value();
    println!("Taken value: {:?}", value);
    println!("Container value: {:?}", container.value);
}

\\ result:
\\ Taken value: Some("Hello, world!")
\\ Container value: None
```