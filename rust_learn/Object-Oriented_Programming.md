
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


# Usage of impl

## impl ... for ...

In Rust, the `impl ... for ...` syntax is used for implementing traits or methods for a specific struct or enum. 