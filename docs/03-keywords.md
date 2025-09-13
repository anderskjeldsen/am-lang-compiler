# Keywords Reference

This document provides a comprehensive reference for all keywords in the Am Lang programming language. Keywords are reserved words that have special meaning and cannot be used as identifiers.

## Core Language Keywords

### `namespace`
Defines a namespace to organize code into logical modules.

```amlang
namespace MyApp {
    // namespace content
}

namespace MyApp.Utils {
    // nested namespace
}
```

### `class`
Declares a class definition.

```amlang
class Person {
    // class members
}

class Person(var name: String, var age: Int) {
    // class with parameters
}
```

### `interface`
Declares an interface that defines a contract for implementing classes.

```amlang
interface Runnable {
    fun run()
}
```

### `fun`
Declares a function or method.

```amlang
fun greet(name: String): String {
    return "Hello, ${name}!"
}
```

### `var`
Declares a mutable variable.

```amlang
var name: String = "Alice"
var age = 25  // type inferred
```

### `const`
Used with `var` to declare an immutable variable (constant).

```amlang
const var PI = 3.14159
const var MAX_SIZE: Int = 100
```

## Access Modifiers

### `private`
Restricts access to the containing class or namespace.

```amlang
class Person {
    private var ssn: String
    
    private fun validateSSN(): Bool {
        // private method
    }
}
```

### `static`
Declares a member that belongs to the class rather than instances.

```amlang
class MathUtils {
    static fun add(a: Int, b: Int): Int {
        return a + b
    }
}
```

## Class Modifiers

### `abstract`
Declares an abstract class that cannot be instantiated directly.

```amlang
abstract class Shape {
    abstract fun area(): Double
}
```

### `open`
Allows a class to be inherited (classes are closed by default).

```amlang
open class Vehicle {
    open fun start() {
        // can be overridden
    }
}
```

### `override`
Indicates that a method overrides a method from a parent class or interface.

```amlang
class Car : Vehicle {
    override fun start() {
        // override implementation
    }
}
```

## Native Integration Keywords

### `native`
Declares that a class or function is implemented in native code (C).

```amlang
native class Thread {
    native fun start()
    native fun join()
}
```

### `primitive`
Declares a primitive type that maps directly to a C type.

```amlang
primitive native class Int {
    override native fun toString(): String
}
```

## Special Keywords

### `import`
Imports classes or namespaces for use in the current scope.

```amlang
import System.IO
import MyNamespace.MyClass
```

### `suspend`
Declares a function that can be suspended and resumed (for asynchronous programming).

```amlang
suspend fun downloadFile(url: String): String {
    // asynchronous operation
}
```

### `op`
Declares an operator overload function.

```amlang
class Vector {
    op + (other: Vector): Vector {
        // vector addition
    }
}
```

## Type Keywords

### `void`
Represents no return value. Functions with void return type are declared by not specifying a return type after the parameter list.

```amlang
fun printMessage() {
    "Hello".print()
    // No return statement needed
}
```

### `enum`
Declares an enumeration type.

```amlang
enum class Color {
    RED, GREEN, BLUE
}
```

### `struct`
Declares a structure type (value type).

```amlang
struct Point {
    var x: Int
    var y: Int
}
```

## Extension Keywords

### `ext`
Declares an extension function that adds functionality to existing types.

```amlang
ext fun String.isEmail(): Bool {
    // extension function implementation
}
```

## Loop Keywords

### `for`
Declares a for loop.

```amlang
for (i in 0 to 10) {
    i.toString().print()
}
```

### `to`
Used in range expressions for loops.

```amlang
for (i in 1 to 100) {
    // loop body
}
```

### `continue`
Skips the current iteration of a loop and continues with the next iteration.

```amlang
for (i in 1 to 10) {
    if (i % 2 == 0) {
        continue  // Skip even numbers
    }
    i.toString().print()
}
```

## Boolean Literals

### `true`
Boolean true value.

```amlang
var isValid = true
```

### `false`
Boolean false value.

```amlang
var isComplete = false
```

## Null Keyword

### `null`
Represents a null reference.

```amlang
var nullable: Int? = null
```

## Control Flow Keywords

### `if`
Conditional statement.

```amlang
if (condition) {
    // statements
}
```

### `else`
Alternative branch for if statements.

```amlang
if (condition) {
    // if branch
} else {
    // else branch
}
```

### `return`
Returns a value from a function.

```amlang
fun add(a: Int, b: Int): Int {
    return a + b
}
```

### `new`
Creates a new instance of a class.

```amlang
var person = new Person("Alice", 25)
```

## Object Creation and Type Keywords

### `this`
Refers to the current instance.

```amlang
class Person {
    fun greet(): String {
        return "Hello, I'm ${this.name}"
    }
}
```

## Keyword Usage Guidelines

### Reserved Status
All keywords are reserved and cannot be used as:
- Variable names
- Function names
- Class names
- Namespace names
- Parameter names

### Case Sensitivity
All keywords are case-sensitive and must be written in lowercase:
- ✓ `class`
- ✗ `Class`, `CLASS`

### Contextual Keywords
Some keywords are contextual and only have special meaning in certain contexts:
- `to` - only special in range expressions
- `var` - can be used as parameter modifier

## Future Reserved Keywords

The following words may become keywords in future versions:
- `match`
- `when`
- `async`
- `await`
- `yield`
- `delegate`

## Examples

### Complete Class Example
```amlang
namespace Examples {
    abstract class Animal(protected var name: String) {
        
        abstract fun makeSound(): String
        
        fun getName(): String {
            return this.name
        }
    }
    
    class Dog : Animal {
        // Note: AmLang inheritance initialization patterns may differ
        fun initializeDog(name: String) {
            // Equivalent to: super(name)
        }
        
        override fun makeSound(): String {
            return "Woof!"
        }
    }
}
```

### Interface Implementation Example
```amlang
interface Drawable {
    fun draw()
}

class Circle : Drawable {
    private var radius: Double
    
    // Note: AmLang interface implementation initialization may differ
    fun initializeCircle(radius: Double) {
        this.radius = radius
    }
    
    override fun draw() {
        "Drawing circle with radius ${radius}".print()
    }
}
```

## Next Steps

- Learn about the [Type System](./04-type-system.md)
- Explore [Variables and Constants](./05-variables-constants.md)
- Understand [Classes and Objects](./06-classes-objects.md)