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
Declares an immutable variable or property (a constant). `const var` is the older spelling: still accepted, but deprecated for local variables.

```amlang
const PI = 3.14159
const MAX_SIZE: Int = 100

class Account(const id: Int, var balance: Int) {   // `const` constructor parameter = read-only property
    const created: Long = 0
}
```

A `const` property can be set only by its initializer, `init { }` and the primary constructor. Any other write, including `this.x = …` in a method, `+=` and `++`, is a compile error.

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

### `shared`
Only before `static`, and only on a property. A plain `static` gets one copy
PER ISOLATE (per thread, under the share-nothing thread model), so two threads
never see each other's writes. `shared static` gets one copy for the whole
process, reachable from every thread.

```amlang
class Counters {
    shared static var total: Int     // one copy, every thread
    static var perThread: Int        // one copy per isolate
}
```

It is **unsynchronised**: no lock, no atomic and no ordering guarantee. A reader
on another thread may see a stale value, and a 64-bit type (`Long`, `ULong`,
`Double`) can tear on a 32-bit target such as m68k, giving half of each of two
values. Use `Am.Threading.Mutex` when that matters.

Primitives only. An object or struct is rejected, because one process-wide copy
would hand a pointer into one isolate's heap to another thread. An initializer
is rejected too: the slot starts at the type's zero value, so assign it in
`main` before starting threads if you need another.

`shared` is contextual, so it remains usable as an ordinary identifier.

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

### `data`
Declares a data class (since v0.15.0): a class whose value is its primary-constructor properties.

```amlang
data class Point(var x: Int, var y: Int)

var a = new Point(1, 2)
a.toString()                 // "Point(x=1, y=2)"
a == new Point(1, 2)         // true: compares the properties
var b = a.copy()             // a new Point with the same values
```

- The compiler generates `equals`, `hash`, `toString` and `copy()` from the primary constructor's properties. `equals` and `hash` agree, so data classes work as `HashMap` keys and `HashSet` elements.
- Every primary-constructor parameter must be a property: `var x` or `const x`. Properties declared in the body take no part.
- Use `const` for values that serve as keys: `data class Point(const x: Int, const y: Int)`. A `var` key changed after insertion changes its hash, and the set or map can no longer find it.
- A member the class declares itself (for example its own `toString`) is kept and not generated.
- `toString` prints `null` for a null property. `copy()` is shallow: object properties are shared, not copied.
- The body is optional. A data class can still have a body with more methods and properties.
- `data` is contextual: it is a modifier only directly before `class`, so it stays usable as a name.

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

## Allocation Scope Keywords

See [Allocation Scopes](./14-allocation-scopes.md) for the full semantics; these
entries cover the spelling.

### `scratch`
Bump-allocates every object created while the block runs — including objects
created by functions it calls — from the isolate's arena, and reclaims the arena
once those objects have died.

```amlang
scratch {
    var report = Report.build(rows)      // these allocations come from the arena
    report.print()
}

var row = scratch new Row(a, b)          // allocation-level form
```

### `keep`
The inverse of `scratch`: forces the normal heap for a block or a single
allocation, for objects meant to outlive the surrounding scratch extent.
Outside any scratch extent it is a no-op, so library code whose allocations are
long-lived by design can use it defensively.

```amlang
scratch {
    var scratchRow = new Row(a, b)       // arena
    keep {
        Registry.add(new Row(a, b))      // normal heap, outlives the block
    }
}
```

### `fast`
The legacy spelling of `scratch`, still accepted. The old name described the
reward rather than the precondition, which invited using it on code whose
objects survive the block — the one case it does not help.

`scratch`, `keep` and `fast` are contextual, so all three remain usable as
ordinary identifiers.

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
Declares a structure type with reference semantics.

**Important**: Structs in AmLang use reference semantics but are allocated on the stack. When you assign one struct variable to another, you're copying the reference (pointer), not the data.

```amlang
struct Point {
    var x: Int
    var y: Int
}

// Struct must be initialized with an initializer
var p1: Point {
    x: 10
    y: 20
}

// Assigning to another variable copies the reference
var p2 = p1  // p2 and p1 point to the same struct data

// Modifying through p2 affects p1
p2.x = 30
p1.x.toString().println()  // Prints: 30

// When moved into an array, struct data is copied
var points = [p1, p2]  // Array contains copies of the struct data
```

**Memory Model**:
- The initializer allocates the struct and creates a hidden variable
- The declared variable is a pointer (`struct MyStruct *`) to the allocated data
- Variable assignment copies the pointer, not the data
- Array insertion copies the struct data into the array

## Extension Keywords

### `ext`
Declares an extension function that adds functionality to existing types. The
receiver is the first parameter; the function lives in a class, and callers
use it as a method of the receiver while that class's namespace is imported
(see `Am.Collections.CollectionExtensions`).

```amlang
class StringExtensions {
    ext fun isEmail(s: String): Bool {
        return s.contains("@")
    }
}

// with the namespace imported:
"a@b.c".isEmail()
```

## Loop Keywords

### `for`
Counts an `Int` loop variable up from a start value to an end value, in steps
of 1. Both bounds are evaluated once, before the first pass. If the end is
below the start, the body does not run.

```amlang
for (i = 0 to 10) {
    i.toString().print()     // 0 1 2 ... 10
}
```

To go over the elements of a collection, use `each(list, item) { ... }`.

### `to`
Ends a `for` range, **including** the end value: `for (i = 1 to 3)` runs with
1, 2 and 3, and `for (i = 0 to 0)` runs once.

```amlang
for (i = 1 to 100) {
    // i = 1 .. 100
}
```

Before 0.15.0, `to` stopped before the end value (what `until` does now).

### `until`
Ends a `for` range, **excluding** the end value. This is the form for indexes:
`for (i = 0 until arr.length())` visits every element, and
`for (i = 0 until 0)` does not run.

```amlang
for (i = 0 until list.getSize()) {
    list.get(i).println()
}
```

### `continue`
Skips the current iteration of a loop and continues with the next iteration.

```amlang
for (i = 1 to 10) {
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

Without braces, `if` is an expression with a value. The `else` is required, and only the chosen branch is evaluated:

```amlang
var sign = if (x < 0) "neg" else if (x == 0) "zero" else "pos"
return if (found) item else null      // a null branch makes the type nullable (Item?)
```

Both branches must have the same type, except that one of them may be `null`.

### `else`
Alternative branch for if statements.

```amlang
if (condition) {
    // if branch
} else {
    // else branch
}
```

### `when`
Multi-way branch (since v0.15.0). The first branch whose condition matches runs; the rest are skipped.

```amlang
when (shape) {
    is Circle -> area = 3.14 * shape.r * shape.r   // smart cast: shape is a Circle here
    is Rect -> {
        area = shape.w * shape.h
    }
    !is Square -> log("not a square")
    else -> area = 0.0
}

when (color) {
    Color.Red -> name = "red"
    Color.Green, Color.Blue -> name = "cool"   // a comma-separated list matches any of them
}

when {                                          // no subject: boolean conditions
    x < 0 -> sign = -1
    x == 0 -> sign = 0
    else -> sign = 1
}
```

- A condition is `is T`, `!is T`, a value (compared with `==`, so strings compare by content), or `else`. `else` must be the last branch and stand alone.
- A body is a `{ block }` or one statement on the rest of the line.
- **Smart cast:** in a branch whose only condition is `is T`, the subject has type `T` — no `as` needed, and that includes writes such as `shape.name = n`. This works for class, interface and `Any` subjects (`is Int`, `is String`). It is not applied in a branch that assigns to the subject.
- The subject is evaluated once. A subject that is not a plain local name is evaluated into a hidden local first.
- `when` can also be a value: `var y = when …`, `return when …`, a function argument or an expression body. Then each branch must be a single expression, not a `{ }` block; an `else` branch is required; and the subject must be a plain variable (store anything else in a local first). It works like the equivalent `if … else if … else` expression, smart casts included:

```amlang
fun area(s: Shape): Int = when (s) {
    is Circle -> s.r * s.r * 3
    is Rect -> s.w * s.h
    else -> 0
}
```
- `when` is contextual: it starts the construct only when `(` or `{` follows, so it stays usable as a name.

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