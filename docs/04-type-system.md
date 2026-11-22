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
- `length(): Int` - Returns string length
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

## Nullable types (v0.13.0)

Bare object and primitive types are non-null. Add `?` to allow null:

```amlang
var title: String = "Ready"
var optionalTitle: String? = null
var count: Int? = null
var displayTitle: String = optionalTitle ?? "Untitled"
```

Safe calls (`?.`) skip the member access when the receiver is null. The `??` operator supplies a fallback, including after a safe-call chain. Nullable-to-non-null conversions may introduce runtime null checks; handle null explicitly when it is an expected value.

`legacyObjectNullability` in `compilerFlags` and `#legacyObjectNullability` are rejected. Remove them from the root package and dependencies when migrating. See the [upgrade guide](../README.md#upgrading-to-v0130).

A safe chain's result is null when any link is null, and is nullable even when
the last member isn't (`node?.kid?.n` is an `Int?`). `==`, `!=`, `!!` and `??`
after the chain apply to that result:

```amlang
node?.kid?.n == null    // true when node or node.kid is null
node?.kid?.n != 7       // true when either is null
node?.kid?.n!!          // throws when either is null
node?.kid?.n ?? -1      // -1 when either is null
```

### Nullable values in operators

A nullable primitive can be the operand of an arithmetic, bitwise or
relational operator, of `!` and of unary `-`, of `&&` and `||` (a `Bool?`), and
the condition of `if` and `while`. The right operand of `&&`/`||` is checked
only when it is evaluated, so `false && flag` doesn't throw when `flag` is null. Where a non-null value is needed
(an operator, a non-null parameter, `var y: Int = x`), the compiler converts it
with a runtime null check, as `x!!` would: a null throws a
`NullArgumentError`/`NullAssignmentError` instead of being read as 0. After a
null guard the check never fires:

```amlang
fun next(x: Int?): Int {
    if (x == null) {
        return 0          // or throw, continue, break
    }
    return x + 1          // x is not null here
}

if (count != null) {
    total = total + count * 2
}
```

There is no flow analysis: the check is made at each use, so a variable set
back to null after its guard throws at the next operator rather than being
accepted by the compiler. `==` and `!=` compare the nullable value itself
(`x == null`; `x == 5` is false when `x` is null). Use `x ?? 0` for a default
instead of a check. (Since 0.16.0; before, `x + 1` on an `Int?` was a C
compile error.)

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

## Enums in an `Any`

An enum value stored in an `Any` remembers which enum it is, so `is` and `as`
tell a `Color` from an `Int` with the same number and from a member of another
enum:

```amlang
var a: Any = Color.blue
a is Color      // true
a is Other      // false, even if Other has a member with Color.blue's value
a as Color      // Color.blue
var n: Any = 2
n is Color      // false
n as Color      // throws "Can't cast Any to Color"
```

The `Any` still holds the enum's backing number: `a.toString()` prints it and
`a as Int` and `a is Int` work as before. A program can tell apart at most 255
enums this way (they are numbered in the order of their qualified names); a test
against an enum past that is a compile error naming the enum.

## Array Types

Arrays are declared with square brackets:
```amlang
var numbers: Int[] = new Int[10]
var names: String[] = ["Alice", "Bob", "Charlie"]
```

### Array literals

An array literal `[a, b, c]` holds any expressions: constants, locals,
parameters, calls, enum values, `new` objects, string concatenation and `null`.
The elements are evaluated once each, left to right, and the array keeps its own
reference to each object element.

```amlang
var a = 5
var xs = [a, 2, Util.twice(3), a * a]   // Int[]
var names = ["x" + a.toString(), "y"]   // String[]
var boxes = [new Box(1), new Box(2)]    // Box[]
sum([a, 1])                             // as an argument
```

The element type comes from where the literal goes, when that has a type: a
declared variable or property (`var xs: Long[] = [a, 1]` holds Longs), a
parameter (`f([a, 1])` with `f(xs: Long[])`), or a return type. Otherwise it is
the elements' common type:

- elements of one type give that type;
- integers of the same signedness widen to the widest (`[i, 3L]` is `Long[]`),
  and `Float` with `Double` gives `Double`;
- objects widen to a base class or interface that another element has
  (`[new Derived(), new Base()]` is `Base[]`);
- a `null` element, or a nullable one, makes the element type nullable
  (`["y", null]` is `String?[]`).

Anything else, such as `Int` with `UInt`, `Int` with `Double` or two unrelated
classes, is an error that asks for a declared type, and so are an empty literal
(`var e: Int[] = []` is fine) and a literal of only nulls.

Arrays of arrays are written `Int[][]` (that is `Array<Array<Int>>`), allocated
with `new Int[][n]` and built from nested literals: `[[1, 2], [3]]`. `Int[]?[]`
is an array of nullable `Int` arrays.

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

### Explicit type arguments on a call

A generic function can be given its type arguments at the call, with or
without a receiver: `List<Int>.newList<Int>()`, `Box<String>.lenOf<Int>(xs)`,
or, inside the class, just `lenOf<Int>(xs)` or `count<Int>(xs)`. The `<` must
touch the name, and the `>` must be followed by `(` or `.`; otherwise `<` and
`>` are comparisons, so `a<b`, `i<n` and `a<b && c>(d)` compare as written.
(`x<y>(z)` with no spaces reads as a call of `x`; write `x < y > (z)` for the
comparison.)

### Type arguments must match

A scalar `Int` converts to `Long` where a `Long` is expected, but an `Int[]`
does not pass as a `Long[]`, nor a `List<Int>` as a `List<Long>` (or as an
`Iterable<Long>`). A generic's elements are stored at their own width, and
passing the container doesn't convert them, so the callee would read the
memory wrongly. The same goes for `Int` against `Int?` (`Int[]` as `Int?[]`,
`List<Color>` as `List<Color?>`): a nullable value is stored with a null flag.
These are compile errors (since 0.16.0):

```
Unable to convert Int[] to Long[]: its Int elements are stored differently from Long, ...
```

Copy element by element into a new array or list of the expected type, or
declare it with that type from the start. The other signedness of the same
width is allowed (`Byte[]` as `UByte[]`, `Int[]` as `UInt[]`), because it reads
the same bits a converted copy would hold.

Object type arguments must match too: a `List<Dog>` does not pass as a
`List<Animal>`, because the callee could add a `Cat` to it, which the caller
would then read as a `Dog`. A plain `Dog` still passes as an `Animal`, and a
`List<String>` passes as a `List<String?>`.

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
3. **Prefer Immutable**: Use `const` when values don't change
4. **Meaningful Names**: Use descriptive type and variable names
5. **Null Checks**: Always handle nullable types safely

## Next Steps

- Learn about [Variables and Constants](./05-variables-constants.md)
- Explore [Classes and Objects](./06-classes-objects.md)
- Understand [Functions](./10-functions.md)