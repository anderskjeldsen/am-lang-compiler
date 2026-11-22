# Functions

This document covers function declarations, parameters, return types, and advanced function features in Am Lang.

## Function Declaration

### Basic Function Syntax

```amlang
fun functionName(parameter1: Type1, parameter2: Type2): ReturnType {
    // function body
    return value
}
```

### Simple Function Examples

```amlang
fun greet(name: String): String {
    return "Hello, ${name}!"
}

fun add(a: Int, b: Int): Int {
    return a + b
}

fun printMessage(message: String) {
    message.println()
}
```

### Expression Bodies

A function whose body is one expression can be written with `=`. The return type must be declared:

```amlang
fun area(): Int = this.width * this.height
static fun sign(x: Int): String = if (x < 0) "neg" else "pos"
```

### Functions Without Return Values

```amlang
fun printNumbers(count: Int) {
    for (i = 1 to count) {
        i.toString().println()
    }
    // No return statement needed
}

fun doSomething() {  // Inferred void return
    "Doing something...".println()
    // No explicit return needed
}
```

**Note**: Functions cannot use the `void` keyword. Functions that don't return a value simply omit the return type specification. The `void` keyword is only used for lambdas.

## Parameters

### Parameter Types

```amlang
fun processData(
    id: Int,                    // Required parameter
    name: String,               // Required parameter
    isActive: Bool,             // Required parameter
    score: Double               // Required parameter
): String {
    return "Processing ${name} (ID: ${id})"
}
```

### Variable Parameters

In class parameters, you can use `var` to automatically create fields:

```amlang
class Person(var name: String, var age: Int) {
    // name and age automatically become class fields
    
    fun introduce(): String {
        return "I'm ${this.name}, ${this.age} years old"
    }
}
```

### Default Values

A parameter can have a default value. A call that leaves the argument out gets the default:

```amlang
fun label(text: String, size: Int = 12, bold: Bool = false): String {
    return "${text} ${size} ${bold}"
}

label("Hi")              // label("Hi", 12, false)
label("Hi", 14)          // label("Hi", 14, false)
```

- A default is a **constant**: a number (`-3` and suffixed literals like `5UI` included), a string without `${...}`, `true`/`false`, a character, or `null`. The caller copies it into the call, so it means the same thing wherever the function is called from. Anything else is a compile error.
- Parameters with defaults come **after** all parameters without one.
- Defaults work on methods, static functions and primary constructors (`class Pt(var x: Int, var y: Int = 0)`), native functions included.
- An override gets the defaults of the function it overrides; declare them on the base.
- When one overload takes the arguments exactly, it wins: with both `k(a: Int)` and `k(a: Int, b: Int = 0)`, `k(1)` calls the first.

### Named Arguments

An argument can name its parameter, `name = value`. Named arguments may come in any order and can skip over parameters that have defaults:

```amlang
label("Hi", bold = true)            // label("Hi", 12, true)
label(bold = true, text = "Hi")     // label("Hi", 12, true)
var p = new Pt(y = 7, x = 2)
```

- Positional arguments come first; a positional argument after a named one is an error.
- Each parameter is given once: a name that repeats, matches no parameter, or names a parameter already given by position is an error.
- Arguments are evaluated in **parameter** order, not the order written.

### Parameter Validation

```amlang
fun divide(numerator: Double, denominator: Double): Double? {
    if (denominator == 0.0) {
        "Error: Division by zero".println()
        return null
    }
    return numerator / denominator
}

fun validateAge(age: Int): Bool {
    if (age < 0) {
        "Error: Age cannot be negative".println()
        return false
    }
    if (age > 150) {
        "Warning: Age seems unusually high".println()
    }
    return true
}
```

## Return Types

### Basic Return Types

```amlang
fun getAge(): Int {
    return 25
}

fun getName(): String {
    return "Alice"
}

fun isValid(): Bool {
    return true
}
```

**Note**: Functions cannot explicitly return void. Functions that don't return a value should simply omit the return statement.

### Nullable Return Types

Functions can return nullable primitive types:
```amlang
fun findUser(id: Int): User {
    // Object types like User can return null without the ? operator
    if (id < 0) {
        return null  // Valid for object types
    }
    return new User("User${id}", 25)
}

fun divide(a: Double, b: Double): Double? {
    if (b == 0.0) {
        return null  // Nullable primitive return
    }
    return a / b
}
```

**Important**: Only primitive types (Int?, Bool?, UShort?, Long?, Double?) can be nullable. Object types (including String) cannot be made nullable.

### Multiple Return Scenarios

```amlang
fun processRequest(request: String): String {
    if (request.isEmpty()) {
        return "Error: Empty request"
    }
    
    if (request.length() > 1000) {
        return "Error: Request too long"
    }
    
    // Process the request
    return "Request processed successfully"
}
```

## Static Functions

### Class Static Functions

```amlang
class MathUtils {
    static fun max(a: Int, b: Int): Int {
        return if (a > b) a else b
    }
    
    static fun min(a: Int, b: Int): Int {
        return if (a < b) a else b
    }
    
    static fun abs(x: Int): Int {
        return if (x < 0) -x else x
    }
}

// Usage
var maximum = MathUtils.max(10, 20)
var minimum = MathUtils.min(5, 3)
```

### Static vs Instance Functions

```amlang
class Calculator {
    var lastResult: Double = 0.0
    
    // Instance function - can access instance fields
    fun addToLast(value: Double): Double {
        this.lastResult += value
        return this.lastResult
    }
    
    // Static function - cannot access instance fields
    static fun add(a: Double, b: Double): Double {
        return a + b
        // Cannot access this.lastResult here
    }
}
```

## Function Overloading

### Method Overloading

```amlang
class Printer {
    fun print(message: String) {
        message.println()
    }
    
    fun print(number: Int) {
        number.toString().println()
    }
    
    fun print(flag: Bool) {
        (if (flag) "true" else "false").println()
    }
    
    fun print(items: String[], separator: String) {
        var result = ""
        for (i = 0 to items.length - 1) {
            if (i > 0) {
                result += separator
            }
            result += items[i]
        }
        result.println()
    }
}
```

### How a call picks an overload

Overloads may share a name and a parameter count as long as their parameter types differ (since v0.15.0; before that, same-count overloads were rejected as duplicates, and calls always bound to the first one). A call picks among them by the static types of its arguments:

- An argument whose class is exactly the parameter's class is the best match. Generic arguments must agree too: `Int[]` does not match `String[]`.
- Next is a subclass or implementing class, and a closer base class beats a more distant one.
- A number can widen to another number type (`Int` to a `Long` parameter), but an exact numeric match wins.
- `Any`, a generic type parameter, a function-typed parameter, and `null` accept anything that fits.

The overload with the best total wins. On a tie, the one declared first wins. The declared type of the argument decides, not its run-time class:

```amlang
static fun kind(s: Shape): String { return "shape" }
static fun kind(c: Circle): String { return "circle" }

kind(new Circle())          // "circle"
var s: Shape = new Circle()
kind(s)                     // "shape"
```

Overloads that are `open`, `override`, or declared in an interface dispatch at run time like any other virtual method. An `override` replaces the overload with the same parameter types.

### Object Creation Patterns

AmLang supports various object creation patterns through class parameters and factory methods:

```amlang
// Primary pattern: class parameters
class Rectangle(var width: Double, var height: Double) {
    fun getArea(): Double {
        return this.width * this.height
    }
}

// Factory methods for alternative creation patterns
class RectangleFactory {
    static fun createSquare(size: Double): Rectangle {
        return new Rectangle(size, size)
    }
    
    static fun createDefault(): Rectangle {
        return new Rectangle(1.0, 1.0)
    }
    
    static fun createFromString(dimensions: String): Rectangle {
        // Parse dimensions and create rectangle
        return new Rectangle(10.0, 5.0)  // Example
    }
}

// Usage examples
var rect1 = new Rectangle(10.0, 5.0)          // Direct creation
var square = RectangleFactory.createSquare(8.0)    // Factory method
var defaultRect = RectangleFactory.createDefault()  // Default creation
```

## Suspend Functions

### Asynchronous Functions

```amlang
class AsyncService {
    suspend fun downloadFile(url: String): String {
        "Starting download from ${url}".println()
        Thread.sleep(2000)  // Simulate async operation
        return "Downloaded content from ${url}"
    }
    
    suspend fun processData(data: String): String {
        "Processing: ${data}".println()
        Thread.sleep(1000)  // Simulate processing
        return "Processed: ${data}"
    }
    
    suspend fun saveToFile(content: String, filename: String): Bool {
        "Saving to ${filename}".println()
        Thread.sleep(500)   // Simulate file operation
        return true
    }
}
```

### Calling Suspend Functions

```amlang
class AsyncWorkflow {
    fun runWorkflow() {
        var service = new AsyncService()
        
        // Note: Actual async/await syntax may vary in implementation
        var content = service.downloadFile("https://example.com/data.txt")
        var processed = service.processData(content)
        var saved = service.saveToFile(processed, "output.txt")
        
        if (saved) {
            "Workflow completed successfully".println()
        }
    }
}
```

## Native Functions

### Native Function Declaration

```amlang
native class FileSystem {
    static native fun exists(path: String): Bool
    static native fun delete(path: String): Bool
    static native fun createDirectory(path: String): Bool
    static native fun getFileSize(path: String): Long
}

native class Thread {
    native fun start()
    native fun join()
    static native fun sleep(milliseconds: Long)
    static native fun getCurrentThreadId(): Long
}
```

### Mixed Native and Regular Functions

```amlang
native class Socket {
    private var connected: Bool = false
    
    native fun connectNative(address: String, port: Int): Bool
    native fun sendNative(data: String): Int
    native fun receiveNative(buffer: String, maxSize: Int): Int
    native fun disconnectNative()
    
    // Regular function that uses native functions
    fun connect(address: String, port: Int): Bool {
        if (this.connected) {
            "Already connected".println()
            return false
        }
        
        "Connecting to ${address}:${port}".println()
        this.connected = this.connectNative(address, port)
        
        if (this.connected) {
            "Connected successfully".println()
        } else {
            "Connection failed".println()
        }
        
        return this.connected
    }
    
    fun send(message: String): Bool {
        if (!this.connected) {
            "Not connected".println()
            return false
        }
        
        var result = this.sendNative(message)
        return result > 0
    }
}
```

## Functions that never throw: `#noThrow`

`#noThrow` before a function promises that it never ends with an exception, so
the compiler can call it without checking for one. The compiler checks the
promise: a body that can throw outside a catch-all `try`/`catch` is a compile
error. On a `native` function the promise is trusted (its C was audited by
hand); on a `suspend` function it is not allowed.

The promise is inherited. Every override of a `#noThrow` function, and every
implementation of a `#noThrow` interface member, must not throw either, whether
it overrides directly, several classes down, or in a generic class. The
`toString()`, `hash()` and `equals()` every class inherits are `#noThrow`
(`AnyInterface`, `Object`), so this applies to your own overrides of them. The
override doesn't repeat `#noThrow`; it has to catch what its body can throw
itself:

```
class Node {
    var next: Node? = null

    override fun toString(): String {
        try {
            return "Node -> " + this.next.toString()
        } catch (e: Exception) {
            return "Node"
        }
    }
}
```

Without the `try`, the build stops with an error that names the override, the
`#noThrow` function it overrides and the first thing in the body that can throw:

```
Program.aml - Line 4: 'App.Node.toString' overrides #noThrow function 'Am.Lang.Any.toString'
and can throw: null check on member access `this.next.toString()` at line 6. An override of
a #noThrow function must not throw: catch it with try/catch (catch (e: Exception)) around the
code that can throw.
```

What can throw: `throw`; `new T[n]` with a size that isn't a non-negative
constant (a negative size throws); `!!`; a checked `as`; a member access
through a nullable value or `Any` (null check); `op=` on a nullable primitive;
`array[i]` (bounds check); a call to a function that can throw; a call through a
lambda or function reference; `new` of a class whose property initializers or
`init { }` blocks (its own or a base class's) can throw. Only a catch-all absorbs them:
`catch (e: Exception)` (or an untyped `catch`), and only for code in the `try`
block. A catch of a narrower type, such as `catch (e: NullReferenceException)`,
doesn't satisfy the promise. The members a `data class` generates already run in
a catch-all.

Allocating doesn't throw: `new` (of a class whose initializers can't throw),
array literals and string templates are fine in a `#noThrow` function, so a
`toString()` can build its string without a `try`:

```
override fun toString(): String {
    return "Node ${this.name}"
}
```

## Out of memory

Running out of memory isn't an exception (since 0.16.0). It can't be caught: the
program shuts down instead, as in Rust, Swift and Go.

- The thread that runs out prints `Out of memory allocating <class>` (or
  `Out of memory at <class> line N`) to stderr (stdout on AmigaOS) without
  allocating.
- On the main thread the program goes straight to its normal shutdown: the
  `#runOnExit` hooks, static properties, the final sweep and each class's
  shutdown run as at a normal exit. The exit status is 1, or 20 (`RETURN_FAIL`)
  on AmigaOS.
- On another thread, that thread stops and tears itself down, and tells the main
  thread to shut down. Main stops the other threads, waits up to 3 seconds for
  them (10 seconds on AmigaOS and MorphOS), then runs the same shutdown.
- A thread sees a stop request when it next calls `Thread.receive()`,
  `Thread.join()` or `Thread.sleep()`, or allocates with `new`. A thread busy in a
  loop that does none of these, or blocked in an operating-system call, isn't
  waited for after the timeout. On AmigaOS and MorphOS such a thread would keep
  running in the program's code after the exit unloads it, so its task is
  removed (`RemTask`) and the program prints
  `Thread 'name' did not stop within 10 s; removed`. What it held is not
  freed: its stack, its objects, and any file or library it had open (such a
  file stays locked until reboot). Elsewhere (and on AROS) the process exit
  ends it. Design threads to call `Thread.sleep()` or `Thread.receive()` in
  long loops, so they stop cleanly.
- If memory runs out again during the shutdown, the remaining `#runOnExit` hooks
  are skipped; the sweep, the class shutdowns and the exit still happen.

The frames that were running when memory ran out are not unwound: their
`finally` blocks don't run. On AmigaOS, MorphOS and AROS, whose exit doesn't
close a program's files or free its locks, the objects they held are released
when their thread ends, after the static properties: each object's release runs
as at any other release, so a `FileStream` they had open is closed and its file
no longer locked. On other platforms that is the am-lang-core feature
`releaseHeapOnExit` (about 3% slower allocation, see the
[feature system](feature-system.md)); without it those objects stay allocated
until the process exits, which closes the files. Cleanup written in the program
itself (a `finally`, a call to `flush()` or `close()` that the frame never
reached) doesn't run either way, so put what must happen in a `#runOnExit` hook
or a class's shutdown.

`OutOfMemoryException` still exists so that old code compiles, but the runtime
no longer throws it, and `catch (e: OutOfMemoryException)` never catches an
allocation failure. To test how a program shuts down, make its allocations fail
with `Arc.failAllocationsAfter(count, sticky)` (`Am.Lang.Diagnostics`).

## Lambdas

A lambda is a function written where a value goes. Its parameter types usually come
from the function type it is passed or assigned to, so the parameters need no types:

```amlang
static fun apply(f: (x: Int) => Int, v: Int): Int {
    return f(v)
}

var a = Program.apply((x) => {          // block body
    return x * 2
}, 3)
var b = Program.apply((x) => x * 2, 3)  // expression body: returns its value
var c = Program.apply(x => x + 1, 3)    // one parameter: no parentheses needed
var d = Program.apply((x) => return x * 3, 3)
var stored: (x: Int) => Int = x => x * 10
```

An expression body returns its value when the function type has a return type. For a
function type that returns nothing, written with a lowercase `void`, the expression is
just run:

```amlang
static fun twice(f: () => void) {
    f()
    f()
}

Program.twice(() => counter.add())
var once: () => void = () => {
    counter.add()
}
```

`Void` with a capital V is not a type; `() => Void` is an error that points to `void`.

### Typed parameters

A parameter may also declare its type, as in a function signature. With nothing to take
a function type from (a local or field without a declared type), the declared types and
what the body returns make the lambda's type:

```amlang
var f = (x: Int) => x * 2               // (x: Int) => Int
var a = f(3)                            // 6; f.run(3) is the same call
var g = (n: Int, s: String) => {        // (n: Int, s: String) => String
    return s + n.toString()
}
var say = (s: String) => s.println()    // returns nothing: (s: String) => void
var count = (l: List<String>) => l.getSize()
var isNull = (s: String?) => s == null
var twice = (h: (n: Int) => Int, v: Int) => h(h(v))
```

A lambda with no parameters has nothing to declare, so its body alone makes the type:
`var z = () => show(4)` is `() => String`, and `var tick = () => counter.add()` is
`() => void`. A lambda local inside a lambda works the same way:

```amlang
var outer = () => {
    var inner = () => 5
    return inner() + 1                  // outer is () => Int
}
```

The result type is the type of an expression body, or of the values the block's
`return` statements give (they must agree: `return 1` and `return 2L` is an error); no
returned value makes a `void` lambda.

Where a function type is expected (a typed variable, field or parameter, a function's
parameter), declared types must be exactly the expected ones, or it's a compile error
that names the parameter and both types:

```amlang
var ok: (x: Int) => Int = (x: Int) => x + 1
var bad: (x: Int) => Int = (x: String) => 1
// Lambda parameter 'x' is declared String, but the function type it is used as expects Int
```

Some parameters typed and some not, `(a: Int, b) => …`, is fine where a function type is
expected (the untyped ones take theirs from it); with none, every parameter needs a type.

A lambda belongs to the class it is written in: its body sees that file's imports and
can use the enclosing function's locals and parameters (also from a lambda inside a
lambda), and compiler errors in it point at that file. This holds when the lambda is
passed to a function of another class, such as `list.filter((w) => ...)`.

## Function Examples

### Utility Functions

```amlang
namespace Utils {
    class StringUtils {
        static fun isEmpty(str: String): Bool {
            return str == null || str.length() == 0
        }
        
        static fun isNotEmpty(str: String): Bool {
            return !StringUtils.isEmpty(str)
        }
        
        static fun reverse(str: String): String {
            if (str.length() <= 1) {
                return str
            }
            
            var result = ""
            for (k = 1 to str.length()) {
                result += str.charAt(str.length() - k)
            }
            return result
        }
        
        static fun contains(haystack: String, needle: String): Bool {
            if (needle.length() == 0) {
                return true
            }
            if (haystack.length() < needle.length()) {
                return false
            }
            
            for (i = 0 to haystack.length() - needle.length()) {
                var found = true
                for (j = 0 to needle.length() - 1) {
                    if (haystack.charAt(i + j) != needle.charAt(j)) {
                        found = false
                        break
                    }
                }
                if (found) {
                    return true
                }
            }
            return false
        }
        
        static fun split(str: String, delimiter: String): String[] {
            if (str.length() == 0) {
                return new String[0]
            }
            
            var parts = new List<String>()
            var current = ""
            
            for (i = 0 to str.length() - 1) {
                var char = str.charAt(i)
                if (char.toString() == delimiter) {
                    parts.add(current)
                    current = ""
                } else {
                    current += char
                }
            }
            
            if (current.length() > 0) {
                parts.add(current)
            }
            
            return parts.toArray()
        }
    }
    
    class ArrayUtils {
        static fun <T> indexOf(array: T[], item: T): Int {
            for (i = 0 to array.length - 1) {
                if (array[i] == item) {
                    return i
                }
            }
            return -1
        }
        
        static fun <T> contains(array: T[], item: T): Bool {
            return ArrayUtils.indexOf(array, item) >= 0
        }
        
        static fun <T> reverse(array: T[]): T[] {
            var result = new T[array.length]
            for (i = 0 to array.length - 1) {
                result[array.length - 1 - i] = array[i]
            }
            return result
        }
        
        static fun join(array: String[], separator: String): String {
            if (array.length == 0) {
                return ""
            }
            
            var result = array[0]
            for (i = 1 to array.length - 1) {
                result += separator + array[i]
            }
            return result
        }
    }
}
```

### Mathematical Functions

```amlang
namespace Math {
    class MathLibrary {
        static const PI: Double = 3.14159265359
        static const E: Double = 2.71828182846
        
        static fun abs(x: Int): Int {
            return if (x < 0) -x else x
        }
        
        static fun abs(x: Double): Double {
            return if (x < 0.0) -x else x
        }
        
        static fun max(a: Int, b: Int): Int {
            return if (a > b) a else b
        }
        
        static fun max(a: Double, b: Double): Double {
            return if (a > b) a else b
        }
        
        static fun min(a: Int, b: Int): Int {
            return if (a < b) a else b
        }
        
        static fun power(base: Double, exponent: Int): Double {
            if (exponent == 0) {
                return 1.0
            }
            
            var result = 1.0
            var exp = MathLibrary.abs(exponent)
            
            for (i = 1 to exp) {
                result *= base
            }
            
            return if (exponent < 0) 1.0 / result else result
        }
        
        static fun factorial(n: Int): Long {
            if (n < 0) {
                return 0L
            }
            if (n <= 1) {
                return 1L
            }
            
            var result = 1L
            for (i = 2 to n) {
                result *= i.toLong()
            }
            return result
        }
        
        static fun fibonacci(n: Int): Long {
            if (n <= 0) {
                return 0L
            }
            if (n == 1) {
                return 1L
            }
            
            var a = 0L
            var b = 1L
            
            for (i = 2 to n) {
                var temp = a + b
                a = b
                b = temp
            }
            
            return b
        }
        
        static fun gcd(a: Int, b: Int): Int {
            var x = MathLibrary.abs(a)
            var y = MathLibrary.abs(b)
            
            while (y != 0) {
                var temp = y
                y = x % y
                x = temp
            }
            
            return x
        }
        
        static fun isPrime(n: Int): Bool {
            if (n <= 1) {
                return false
            }
            if (n <= 3) {
                return true
            }
            if (n % 2 == 0 || n % 3 == 0) {
                return false
            }
            
            var i = 5
            while (i * i <= n) {
                if (n % i == 0 || n % (i + 2) == 0) {
                    return false
                }
                i += 6
            }
            
            return true
        }
    }
}
```

### Validation Functions

```amlang
namespace Validation {
    class Validator {
        static fun isValidEmail(email: String): Bool {
            if (StringUtils.isEmpty(email)) {
                return false
            }
            
            var atIndex = email.indexOf("@")
            if (atIndex <= 0 || atIndex >= email.length() - 1) {
                return false
            }
            
            var dotIndex = email.lastIndexOf(".")
            if (dotIndex <= atIndex || dotIndex >= email.length() - 1) {
                return false
            }
            
            return true
        }
        
        static fun isValidPhoneNumber(phone: String): Bool {
            if (StringUtils.isEmpty(phone)) {
                return false
            }
            
            var digits = 0
            for (i = 0 to phone.length() - 1) {
                var char = phone.charAt(i)
                if (char.isDigit()) {
                    digits++
                } else if (char != '-' && char != ' ' && char != '(' && char != ')') {
                    return false
                }
            }
            
            return digits >= 10 && digits <= 15
        }
        
        static fun isStrongPassword(password: String): Bool {
            if (password.length() < 8) {
                return false
            }
            
            var hasUpper = false
            var hasLower = false
            var hasDigit = false
            var hasSpecial = false
            
            for (i = 0 to password.length() - 1) {
                var char = password.charAt(i)
                if (char.isUpperCase()) {
                    hasUpper = true
                } else if (char.isLowerCase()) {
                    hasLower = true
                } else if (char.isDigit()) {
                    hasDigit = true
                } else {
                    hasSpecial = true
                }
            }
            
            return hasUpper && hasLower && hasDigit && hasSpecial
        }
        
        static fun validateRange(value: Int, min: Int, max: Int): Bool {
            return value >= min && value <= max
        }
        
        static fun validateNotNull<T>(value: T?, fieldName: String): Bool {
            if (value == null) {
                "Error: ${fieldName} cannot be null".println()
                return false
            }
            return true
        }
    }
}
```

## Best Practices

### 1. Function Naming
```amlang
// Good - descriptive names
fun calculateTotalPrice(items: Product[], taxRate: Double): Double
fun isValidUser(user: User): Bool
fun sendEmailNotification(recipient: String, subject: String): Bool

// Poor - unclear names
fun calc(items: Product[], rate: Double): Double
fun check(user: User): Bool
fun send(to: String, sub: String): Bool
```

### 2. Function Length
```amlang
// Good - focused, single responsibility
fun validateUser(user: User): Bool {
    return user != null && 
           !user.getName().isEmpty() && 
           user.getAge() >= 0
}

fun processUser(user: User) {
    if (validateUser(user)) {
        saveUser(user)
        sendWelcomeEmail(user)
    }
}

// Poor - too long, multiple responsibilities
fun processAndValidateUser(user: User) {
    // 50+ lines of validation and processing
}
```

### 3. Parameter Validation
```amlang
fun divide(a: Double, b: Double): Double? {
    if (b == 0.0) {
        "Division by zero error".println()
        return null
    }
    return a / b
}

fun processArray<T>(array: T[]): T[] {
    if (array == null || array.length == 0) {
        return new T[0]
    }
    // Process array
    return array
}
```

### Return Type Consistency
```amlang
// Good - consistent return types with objects
fun findUserById(id: Int): String     // Returns user name or null  
fun findUserByEmail(email: String): String  // Returns user name or null

// Poor - inconsistent return handling
fun findUserById(id: Int): String      // Might throw exception
fun findUserByEmail(email: String): String  // Returns null
```

### 5. Error Handling
```amlang
fun safeDivide(a: Double, b: Double): Result<Double> {
    if (b == 0.0) {
        return Result.error("Division by zero")
    }
    return Result.success(a / b)
}

class Result<T> {
    private var value: T?
    private var error: String
    private var isSuccess: Bool
    
    static fun <T> success(value: T): Result<T> {
        var result = new Result<T>()
        result.value = value
        result.isSuccess = true
        return result
    }
    
    static fun <T> error(message: String): Result<T> {
        var result = new Result<T>()
        result.error = message
        result.isSuccess = false
        return result
    }
}
```

## Next Steps

- Learn about [Classes and Objects](./06-classes-objects.md)
- Explore [Threading and Concurrency](./11-threading.md)
- Understand [Native Integration](./12-native-integration.md)