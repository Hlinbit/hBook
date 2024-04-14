# Result 

`Result` needs to specify the success return type and failure return type through the template.
For example `Result<String, String>` means that `Ok` returns `String` and `Err` returns `String`. `Result<String>` will lead to a compiling error.

```rust
pub fn generate_nametag_text(name: String) -> Result<String, String> {
    if name.is_empty() {
        Err(format!("`name` was empty; it must be nonempty."))
    } else {
        Ok(format!("Hi! My name is {}", name))
    }
}
```

# Custom error type

```rust
impl error::Error for CreationError {}
```


# Result for main function

```rust
fn main() -> Result<(), Box<dyn error::Error>> {
    return Ok(())
}
```

# Recover multiple types of errors

```rust
impl error::Error for CreationError {}

fn main() -> Result<(), Box<dyn error::Error>> {
    let pretend_user_input = "42";
    let x: i64 = pretend_user_input.parse()?;   // possible ParseIntError
    println!("output={:?}", PositiveNonzeroInteger::new(x)?); // possible CreationError
    Ok(())
}
```

# simplification techniques


`?` example:

```rust
fn total_cost(item_quantity: &str) -> Result<i32, ParseIntError> {
    let processing_fee = 1;
    let cost_per_item = 5;
    let qty = item_quantity.parse::<i32>()?;

    Ok(qty * cost_per_item + processing_fee)
}
```

If there is an error for `item_quantity.parse::<i32>()`, the line will return `ParseIntError` immediately. If `item_quantity.parse::<i32>()` sucessed, it will return a `i32` value, equaling to `item_quantity.parse::<i32>().unwarp()`.

# `map_err` function 

Using catch-all error types like `Box<dyn error::Error>` isn't recommended for library code, where callers might want to make decisions based on the error content, instead of printing it out or propagating it further. Here, we define a custom error type `ParsePosNonzeroError` to make it possible for callers to decide what to do next when our function returns an error.

Maps a Result<T, E> to Result<T, F> by applying a function to a contained Err value, leaving an Ok value untouched. This function can be used to pass through a successful result while handling an error.

```rust
use std::num::ParseIntError;

#[derive(PartialEq, Debug)]
enum ParsePosNonzeroError {
    Creation(CreationError),
    ParseInt(ParseIntError),
}

#[derive(PartialEq, Debug)]
struct PositiveNonzeroInteger(u64);

impl PositiveNonzeroInteger {
    fn new(value: i64) -> Result<PositiveNonzeroInteger, CreationError> {
        match value {
            x if x < 0 => Err(CreationError::Negative),
            x if x == 0 => Err(CreationError::Zero),
            x => Ok(PositiveNonzeroInteger(x as u64)),
        }
    }
}

#[derive(PartialEq, Debug)]
enum CreationError {
    Negative,
    Zero,
}

impl ParsePosNonzeroError {
    fn from_creation(err: CreationError) -> ParsePosNonzeroError {
        ParsePosNonzeroError::Creation(err)
    }

    fn from_parseint(err: ParseIntError) -> ParsePosNonzeroError {
        ParsePosNonzeroError::ParseInt(err)
    }
}

fn parse_pos_nonzero(s: &str) -> Result<PositiveNonzeroInteger, ParsePosNonzeroError> {
    // parse fail, mapping ParseIntError to ParsePosNonzeroError by map_err
    // parse successed, return i64, equaling to s.parse().unwrap()
    let x: i64 = s.parse().map_err(ParsePosNonzeroError::from_parseint)?;

    // new fail, mapping CreationError to ParsePosNonzeroError by map_err.
    // new successed, return PositiveNonzeroInteger.
    PositiveNonzeroInteger::new(x).map_err(ParsePosNonzeroError::from_creation)
}

fn main() {
    let input = "123";
    match parse_pos_nonzero(input) {
        Ok(..) => println!("success"),
        Err(ParsePosNonzeroError::ParseInt(err)) => println!("ParseIntError, {}", err),
        Err(ParsePosNonzeroError::Creation(CreationError::Negative)) => println!("Negative"),
        Err(ParsePosNonzeroError::Creation(CreationError::Zero)) => println!("Zero"),
    }
}

```