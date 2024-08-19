# 简析C++中的多态

C++作为一门面向对象的语言，提供了完整的对多态特性的支持。

多态作为面向对象三大特性之一，其目的是允许使用相同的接口来调用不同的实际方法。它分为编译时多态性（如函数重载和运算符重载）和运行时多态性（如虚函数）。通过多态性，程序可以在运行时决定调用哪个方法，从而提高了灵活性和可扩展性。

# 编译时多态性

编译时多态性通过函数重载和运算符重载实现，在编译期间就确定了具体调用的函数或运算符。

函数重载是指多个函数虽然有相同的函数名，但是有不同的输入和输出类型，编译器会按照输入类型，确定具体的实现。
```C++
class Math {
public:
    // 重载的 add 函数：两个整数相加
    int add(int a, int b) {
        return a + b;
    }

    // 重载的 add 函数：两个浮点数相加
    double add(double a, double b) {
        return a + b;
    }

    // 重载的 add 函数：三个整数相加
    int add(int a, int b, int c) {
        return a + b + c;
    }
};

```

运算符重载是另一种编译时多态的形式，允许为用户自定义的类型定义特定的运算符行为。正如下面这个例子，`+`运算符并不原生支持两个`Complex`类型的变量相加，但是通过定义`Complex`的`+`运算符行为，我们也可以实现`Complex`类型的相加。可以说运算符重载极大地扩展了C++语言本身的功能边界。

```C++
class Complex {
private:
    double real;
    double imag;

public:
    Complex(double r = 0.0, double i = 0.0) : real(r), imag(i) {}

    // 重载加法运算符
    Complex operator+(const Complex& other) const {
        return Complex(real + other.real, imag + other.imag);
    }

    void display() const {
        std::cout << "(" << real << ", " << imag << ")" << std::endl;
    }
};
int main() {
    Complex c1(1.0, 2.0);
    Complex c2(3.0, 4.0);

    Complex c3 = c1 + c2;
}
```
# 运行时多态性

运行时多态性（Runtime Polymorphism）在 C++ 中主要通过虚函数（virtual functions）和继承（inheritance）实现。这种多态性允许在运行时根据对象的实际类型来调用适当的函数版本。本节将会探究C++运行时多态的原理，应用运行时多态的注意事项以及运行时多态的意义。

## 基于虚函数和继承的多态

在C++中，我们借助虚函数和继承来实现多态。虚函数的实现依赖于一个称为虚函数表（virtual table，或vtable）的机制。每个包含虚函数的类都有一个虚函数表，表中存储了该类的虚函数的地址。对象在创建时，会包含一个指向其所属类的虚函数表的指针，称为虚表指针（vptr）。

我们可以通过以下例子来侧面证明虚表指针的存在：
```C++
#include <iostream>

class Base {
public:
    virtual void show() {
        std::cout << "Base class show function" << std::endl;
    }

    virtual ~Base() = default; // 虚析构函数
};

class Derived : public Base {
public:
    void show() override {
        std::cout << "Derived class show function" << std::endl;
    }
};

int main() {
    Base* b;
    Derived d;
    b = &d;
    void (*funcPtr)();

    b->show(); 
    std::cout << "b size = " << sizeof(b) << ", d size = " << sizeof(d) << std::endl;
    std::cout << "function ptr size = " << sizeof(funcPtr) << std::endl;

    return 0;
}
// Output:
// Derived class show function
// b size = 8, d size = 8
// function ptr size = 8
```

Output的第一行是虚函数的运行结果，执行的是派生类的定义。第二行分别展示了对象占用的内存。从定义来看，基类和派生类都没有成员函数，其占用内存应该是0，但是因为有虚函数，导致对象中必须存在虚表指针来索引虚函数，因此会有一个隐形的，大小为函数指针的成员变量。因此两个对象的大小都与函数指针大小相同，为8。

## 虚函数中几种特殊情况

通过对上面例子的解析，我们对虚函数的有了一个基本的认识：
派生类的指针（引用）可以赋值给基类指针（引用）；调用虚函数时，会通过虚表指针执行实际类型所定义的虚函数。

对于虚函数来说又有几种特殊的情况需要注意：
- override修饰的虚函数
- final修饰的虚函数
- 虚析构函数
- 纯虚函数

接下来我们按照顺序逐一介绍这四种特殊情况。

### `override`修饰的虚函数

`override` 关键字用于显式声明派生类中的函数重写了基类中的虚函数。这可以帮助编译器检查函数签名是否正确匹配基类中的虚函数，从而避免错误。

下面这个例子展示了一个`override`修饰的虚函数`show(int id)`。在这里`override`主要起到两个作用：
- 提醒程序员这是一个对基类虚函数的重写。
- 提示编译器检查函数签名是否正确匹配基类中的虚函数。

其中第一点是为了增强代码可读性，而第二点则是通过编译器约束我们对虚函数的重写。在例子中，如果我们在重写中错误定义函数签名，那么编译器会报错。而如果我们不使用`override`修饰对虚函数的重写，那么将会直接导致：在派生类定义的函数无法对虚函数重写，进而发生不易被察觉的致命错误。

```C++
#include <iostream>
class Base {
public:
    virtual void show(int id) {
        std::cout << "Base class show function, id = " << id << std::endl;
    }
};

class Derived : public Base {
public:
    void show(int id) override {
        std::cout << "Derived class show function, id = " << id << std::endl;
    }
    /*
    Compile error: Overridden function signature does not match

    void show(float id) override {
        std::cout << "Derived class show function, id = " << id << std::endl;
    }
    */
};

int main() {
    Base* b = new Derived();
    b->show(1); 
    delete b;
    return 0;
}

// Output: Derived class show function, id = 1
```

### `final`修饰的虚函数

在 C++ 中，`final` 关键字可以用来修饰虚函数，以防止该函数在派生类中被再次重写。`final` 关键字还可以用来修饰类，以防止该类被继承。使用 `final` 关键字可以提高代码的安全性和稳定性，明确表明设计意图，防止意外的重写或继承。

```C++
#include <iostream>

class Base {
public:
    // 基类中的虚函数
    virtual void show() {
        std::cout << "Base show()" << std::endl;
    }
};

class Derived : public Base {
public:
    // 重写基类的虚函数，并使用 final 关键字防止进一步重写
    void show() override final {
        std::cout << "Derived show()" << std::endl;
    }
};

// 试图进一步重写 show() 函数会导致编译错误
class FurtherDerived : public Derived {
public:
    // Compile error: Because show() is marked final in Derived class
    // void show() override {
    //     std::cout << "FurtherDerived show()" << std::endl;
    // }
};

int main() {
    Base* basePtr = new FurtherDerived();
    basePtr->show(); // 调用 Derived::show()
    delete basePtr;
    return 0;
}

// Output: Derived show()
```

### 虚析构函数

利用C++多态特性时需要特别注意虚析构函数的使用，如果使用不慎极易导致内存泄露的问题。如以下这个例子：

```C++
#include <iostream>

class Base {
public:
    ~Base() {
        std::cout << "Base destructor called" << std::endl;
    }
};
class Derived : public Base {
public:
    ~Derived() {
        std::cout << "Derived destructor called" << std::endl;
    }
};
int main() {
    Base* ptr = new Derived();
    delete ptr;
    return 0;
}
//  Output:
//  Base destructor called
```

当我们销毁`ptr`时，只调用了基类的析构函数。如果派生类析构函数中有重要的内存释放的操作，而没有被执行，将会导致内存泄露的问题。那么为什么会出先这样的情况呢？

C++在创建派生类时，会先调用基类构造函数，然后再调用派生类的构造函数。当析构派生类时，情况则开始变得复杂。因为在创建时，我们会明确指定派生类的构造函数构建对象，因此，编译器会根据派生关系逐一调用基类和派生类的构造函数。但是如果我们将派生类指针（引用）赋值给基类指针（引用）时，编译器将会失去对变量真正类型的跟踪。这就导致，如果我们不使用虚析构函数，销毁基类指针指向的派生类对象时，只会调用基类的析构函数，而无法调用派生类的析构函数。

而避免这种问题的方式是使用虚析构函数：
```C++
#include <iostream>

class Base {
public:
    virtual ~Base() {
        std::cout << "Base destructor called" << std::endl;
    }
};

class Derived : public Base {
public:
    ~Derived() override {
        std::cout << "Derived destructor called" << std::endl;
    }
};

int main() {
    Base* ptr = new Derived();
    delete ptr;
    return 0;
}
// Output:
// Derived destructor called
// Base destructor called
```

### 纯虚函数

纯虚函数是没有实现的虚函数，必须在派生类中实现。声明一个纯虚函数的语法是在函数声明的末尾加上 = 0。包含纯虚函数的类被称为抽象类，它无法被实例化。而派生于抽象类的类型必须要实现纯虚函数，程序才能正确被编译。

抽象类可能让人联想到其他语言中`interface`的概念。但是需要注意的是：抽象类本质上还是一个`class`，是允许定义普通成员函数，允许拥有成员变量的。如下面的例子所示：

```C++
#include <iostream>

// 抽象类，包含普通成员函数和成员变量
class AbstractBase {
public:
    // 纯虚函数
    virtual void show() = 0;
    AbstractBase(int val) : value(val) {}
    int value;

    // 普通成员函数
    void display() {
        std::cout << "AbstractBase display(), value = " << value << std::endl;
    }
    virtual ~AbstractBase() = default;
};

// 派生类，必须实现所有纯虚函数
class Derived : public AbstractBase {
public:
    Derived(int val) : AbstractBase(val) {}

    void show() override {
        std::cout << "Derived show(), value = " << value << std::endl;
    }
};

int main() {
    // AbstractBase base(10); // 不允许实例化抽象类

    Derived derived(42);
    derived.show(); // 调用 Derived::show()
    derived.display(); // 调用 AbstractBase::display()

    AbstractBase* basePtr = &derived;
    basePtr->show(); // 通过基类指针调用 Derived::show()
    basePtr->display(); // 通过基类指针调用 AbstractBase::display()
    
    return 0;
}
```
抽象类中的`display`函数被派生类继承，可以被派生类调用。同时派生类初始化列表中初始化了基类，这看起来好像违反了**抽象类不能实例化的原则**，但是抽象类的构造函数是被派生类的构造函数调用的，而不是直接创建抽象类的实例，而`AbstractBase`并没有真正实例化。

## 运行时多态的意义

本节主要探讨运行时多态的意义。运行时多态在多种语言中有不同的体现，例如Golang和Java中使用`interface`实现运行时多态，rust中使用`Trait`来实现运行时多态。而C++使用虚函数和继承实现运行时多态。为什么运行时多态如此重要？

在下面这个例子中`Rectangle`，`Circle`和`Triangle`派生自`Shape`，在`main`函数中通过`vector<std::shared_ptr<Shape>>`统一管理不同类型的派生类，通过不同派生类实现的`area()`函数，针对不同类型，执行不同的逻辑。

通过这个例子，我们可以发现：运行时多态使得程序设计更加灵活和可扩展。通过一个基类，通过它操作不同的派生类或实现类，而不需要知道这些类型的具体实现细节，提高了代码的可维护性。在后续的开发中，可以添加新的类而不需要修改现有的代码。

除此之外，许多设计模式（如策略模式、状态模式、命令模式等）依赖于运行时多态。它们通过接口或抽象类定义一组行为，在运行时选择具体的实现，从而达到解耦和灵活扩展的目的。

在测试中我们也需要这样的一种特性。通过创建模拟对象（mock objects）来替代实际的对象，实现隔离测试特定的功能或模块。这在Golang的单元测试框架中有很多应用。

```C++
#include <iostream>
#include <vector>
#include <memory>

// 基类 Shape，包含一个纯虚函数 area()
class Shape {
public:
    virtual ~Shape() = default; // 虚析构函数
    virtual double area() const = 0; // 纯虚函数，表示所有派生类都必须实现该函数
};

// 派生类 Circle，继承自 Shape
class Circle : public Shape {
private:
    double radius;

public:
    Circle(double r) : radius(r) {}

    // 重写 area() 函数
    double area() const override {
        return 3.14159 * radius * radius;
    }
};

// 派生类 Rectangle，继承自 Shape
class Rectangle : public Shape {
private:
    double width;
    double height;

public:
    Rectangle(double w, double h) : width(w), height(h) {}

    // 重写 area() 函数
    double area() const override {
        return width * height;
    }
};

// 派生类 Triangle，继承自 Shape
class Triangle : public Shape {
private:
    double base;
    double height;

public:
    Triangle(double b, double h) : base(b), height(h) {}

    // 重写 area() 函数
    double area() const override {
        return 0.5 * base * height;
    }
};

int main() {
    // 创建一个指向 Shape 基类的指针数组
    std::vector<std::shared_ptr<Shape>> shapes;

    // 向数组中添加不同的形状
    shapes.push_back(std::make_shared<Circle>(5.0));
    shapes.push_back(std::make_shared<Rectangle>(4.0, 6.0));
    shapes.push_back(std::make_shared<Triangle>(4.0, 7.0));

    // 遍历数组并计算每个形状的面积
    for (const auto& shape : shapes) {
        std::cout << "Shape area: " << shape->area() << std::endl;
    }

    return 0;
}
```


