# Type System

Am Lang features a strong static type system that provides type safety while maintaining performance and interoperability with C code.

## Overview

The Am Lang type system includes:
- Primitive types that map directly to C types
- Object types for classes and interfaces
- Nullable types for safe null handling
- Generic types for type-safe collections
- Native types for C interoperability

## Primitive Types

### Integer Types

#### `Int`
32-bit signed integer, equivalent to C's `int`.
```amlang
var count: Int = 42
var negative: Int = -10
```

#### `Long`
64-bit signed integer, equivalent to C's `long long`.
```amlang
var bigNumber: Long = 1234567890L
var timestamp: Long = System.currentTimeMillis()
```

### Boolean Type

#### `Bool`
Boolean type with values `true` or `false`.
```amlang
var isReady: Bool = true
var isComplete: Bool = false
```

### String Type

#### `String`
Immutable string type with UTF-8 encoding.
```amlang
var message: String = "Hello, World!"
var empty: String = ""
```

String methods:
- `getLength(): Int` - Returns string length
- `print()` - Prints to stdout
- `println()` - Prints with newline
- `toString(): String` - Returns self (for consistency)

### Character Type

#### `UShort`
Characters are represented by unsigned 16-bit integers.
```amlang
var letter: UShort = 'A'
var digit: UShort = '5'
```

## Object Types

### `Object`
Base class for all non-primitive types.
```amlang
class Person : Object {
    override fun toString(): String {
        return "Person"
    }
}
```

All classes implicitly inherit from `Object` if no other base class is specified.

## Nullable Types

Am Lang supports nullable types for primitive types only to handle null references safely.

### Nullable Declaration
Add `?` after the primitive type name to make it nullable:
```amlang
var maybeInt: Int? = 42
var maybeBool: Bool? = null
var maybeUShort: UShort? = null
```

**Note**: Only primitive types (Int, Bool, UShort, Long, Double) can be nullable. Object types (String, User, Person, etc.) cannot be made nullable with the `?` operator.

### Null Safety
The compiler enforces null checking for nullable primitive types:
```amlang
var count: Int? = getCount()

// Compiler error - might be null
count.toString()

// Safe access with null check
if (count != null) {
    count.toString()  // OK - compiler knows it's not null
}

// Safe call operator
count?.toString()  // Only calls if not null
```

## Type Inference

Am Lang supports type inference to reduce verbosity:
```amlang
// Explicit type
var message: String = "Hello"

// Type inferred as String
var message = "Hello"

// Type inferred as Int
var count = 42

// Type inferred as Long
var bigNum = 1234L
```

## Array Types

Arrays are declared with square brackets:
```amlang
var numbers: Int[] = new Int[10]
var names: String[] = new String[] {"Alice", "Bob", "Charlie"}
```

## Type Casting

### Explicit Casting
```amlang
var obj: Object = "Hello"
var str: String = obj as String
```

### Type Checking
```amlang
if (obj is String) {
    // obj is automatically cast to String in this block
    obj.print()
}
```

## Generic Types

Generic types provide type safety for collections and containers:
```amlang
class List<T> {
    fun add(item: T) {
        // implementation
    }
    
    fun get(index: Int): T {
        // implementation
    }
}

var stringList: List<String> = new List<String>()
var intList: List<Int> = new List<Int>()
```

## Native Types

Native types map directly to C types for interoperability:

```amlang
primitive native class Int {
    override native fun toString(): String
}

primitive native class CPointer {
    native fun deref(): Object
}
```

## Type Compatibility

### Inheritance Hierarchy
```amlang
class Animal { }
class Dog : Animal { }

var animal: Animal = new Dog()  // OK - upcast
var dog: Dog = animal           // Error - downcast requires explicit cast
```

### Interface Implementation
```amlang
interface Drawable {
    fun draw()
}

class Circle : Drawable {
    override fun draw() { }
}

var drawable: Drawable = new Circle()  // OK
```

## Type Annotations

### Variable Type Annotations
```amlang
var name: String        // Declaration without initialization
var age: Int = 25       // Declaration with initialization
var height: Double      // Must be initialized before use
```

### Function Parameter Types
```amlang
fun greet(name: String, age: Int): String {
    return "Hello ${name}, you are ${age} years old"
}
```

### Function Return Types
```amlang
fun getName(): String {
    return "Alice"
}

fun processData() {  // Inferred void return - no explicit return needed
    // process data
    // no return statement
}

fun calculate(): Int {
    return 42
}
```

**Note**: Functions cannot explicitly return void with a `return void` statement. Functions without return statements or return type annotations are inferred to return void.

## Type Conversions

### Automatic Conversions
Limited automatic conversions are supported:
```amlang
var num: Long = 42  // Int to Long is automatic
```

### Explicit Conversions
```amlang
var str: String = "123"
var num: Int = str.toInt()

var obj: Object = 42
var num: Int = obj as Int
```

## Special Types

### `void`
Represents no return value:
```amlang
fun printMessage() {
    "Hello".print()
    // No return statement needed for void functions
}
```

### Function Types
Functions are first-class citizens:
```amlang
var operation: (Int, Int) -> Int = add
fun add(a: Int, b: Int): Int {
    return a + b
}
```

## Type System Examples

### Basic Types Example
```amlang
namespace TypeExample {
    class TypeDemo {
        static fun main() {
            // Primitive types
            var count: Int = 42
            var flag: Bool = true
            var message: String = "Hello"
            
            // Nullable primitive types only
            var optionalInt: Int? = null
            
            // Type inference
            var inferred = "This is a string"
            
            // Arrays
            var numbers = new Int[] {1, 2, 3, 4, 5}
            
            // Object types
            var person: Person = new Person("Alice", 25)
        }
    }
    
    class Person(private var name: String, private var age: Int) {
        
        fun getName(): String {
            return this.name
        }
        
        fun getAge(): Int {
            return this.age
        }
    }
}
```

### Generic Types Example
```amlang
namespace GenericExample {
    class Container<T>(private var value: T) {
        
        fun getValue(): T {
            return this.value
        }
        
        fun setValue(value: T) {
            this.value = value
        }
    }
    
    class Main {
        static fun main() {
            var stringContainer: Container<String> = new Container<String>("Hello")
            var intContainer: Container<Int> = new Container<Int>(42)
            
            stringContainer.getValue().print()
            intContainer.getValue().toString().print()
        }
    }
}
```

## Type Safety Benefits

1. **Compile-time Error Detection**: Type errors are caught at compile time
2. **IntelliSense Support**: Better IDE support with type information
3. **Refactoring Safety**: Type information helps with safe refactoring
4. **Documentation**: Types serve as documentation for function contracts
5. **Performance**: No runtime type checking overhead

## Best Practices

1. **Use Type Inference**: Let the compiler infer obvious types
2. **Explicit Nullable**: Always explicitly mark nullable types
3. **Prefer Immutable**: Use `const var` when values don't change
4. **Meaningful Names**: Use descriptive type and variable names
5. **Null Checks**: Always handle nullable types safely

## Next Steps

- Learn about [Variables and Constants](./05-variables-constants.md)
- Explore [Classes and Objects](./06-classes-objects.md)
- Understand [Functions](./10-functions.md)