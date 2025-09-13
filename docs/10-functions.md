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

### Functions Without Return Values

```amlang
fun printNumbers(count: Int) {
    for (i in 1 to count) {
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
        for (i in 0 to items.length - 1) {
            if (i > 0) {
                result += separator
            }
            result += items[i]
        }
        result.println()
    }
}
```

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
            for (i in str.length() - 1 to 0) {
                result += str.charAt(i)
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
            
            for (i in 0 to haystack.length() - needle.length()) {
                var found = true
                for (j in 0 to needle.length() - 1) {
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
            
            for (i in 0 to str.length() - 1) {
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
            for (i in 0 to array.length - 1) {
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
            for (i in 0 to array.length - 1) {
                result[array.length - 1 - i] = array[i]
            }
            return result
        }
        
        static fun join(array: String[], separator: String): String {
            if (array.length == 0) {
                return ""
            }
            
            var result = array[0]
            for (i in 1 to array.length - 1) {
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
        static const var PI: Double = 3.14159265359
        static const var E: Double = 2.71828182846
        
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
            
            for (i in 1 to exp) {
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
            for (i in 2 to n) {
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
            
            for (i in 2 to n) {
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
            for (i in 0 to phone.length() - 1) {
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
            
            for (i in 0 to password.length() - 1) {
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