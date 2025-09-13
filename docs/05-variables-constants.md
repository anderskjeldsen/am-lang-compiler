# Variables and Constants

This document covers variable declarations, constants, and variable management in Am Lang.

## Variable Declarations

### Mutable Variables (`var`)

Use `var` to declare mutable variables:

```amlang
var name: String = "Alice"
var age: Int = 25
var height: Double = 5.8
```

### Type Inference

The compiler can infer types from the initial value:

```amlang
var message = "Hello, World!"  // Type inferred as String
var count = 42                 // Type inferred as Int
var isReady = true            // Type inferred as Bool
var bigNumber = 1234L         // Type inferred as Long
```

### Uninitialized Variables

Variables can be declared without initialization, but must be assigned before use:

```amlang
var name: String              // Declaration only
// name.print()               // Compiler error - uninitialized
name = "Alice"                // Assignment
name.print()                  // OK - now initialized
```

## Constants (`const var`)

Use `const var` to declare immutable variables (constants):

```amlang
const var PI = 3.14159
const var MAX_USERS: Int = 1000
const var COMPANY_NAME = "Acme Corp"
```

### Compile-time Constants

Constants must be initialized with compile-time known values:

```amlang
const var MAX_SIZE = 100              // OK - literal
const var GREETING = "Hello"          // OK - string literal
const var DEFAULT_TIMEOUT = 30 * 1000 // OK - compile-time expression

// const var current = getCurrentTime() // Error - runtime value
```

## Nullable Variables

### Nullable Type Declaration

Add `?` to make a primitive variable nullable:

```amlang
var age: Int? = 25
var flag: Bool? = null
// Note: Only primitive types can be nullable, not objects
// var person: Person? = getPerson()  // This is not supported
```

### Null Safety

The compiler enforces null checking:

```amlang
var count: Int? = getCount()

// Compiler error - might be null
// count.toString()

// Safe access patterns:

// 1. Explicit null check
if (count != null) {
    count.toString()  // OK - compiler knows it's not null
}

// 2. Safe call operator
count?.toString()     // Only calls if not null

// 3. Null coalescing (if supported)
// var value = count ?: 0
```

## Variable Scope

### Local Variables

Variables declared within functions or blocks have local scope:

```amlang
fun example() {
    var localVar = "I'm local"
    
    if (true) {
        var blockVar = "I'm in a block"
        localVar.print()    // OK - access outer scope
    }
    
    // blockVar.print()    // Error - blockVar not in scope
}
```

### Class Fields

Variables declared in classes are instance fields:

```amlang
class Person(var name: String, var age: Int) {
    static var count: Int = 0  // Static field
    
    // Note: In AmLang, complex initialization logic may require 
    // different patterns since constructor keyword doesn't exist
    fun initialize() {
        count++
    }
}
```

## Access Modifiers

### Private Variables

Use `private` to restrict access to the containing class:

```amlang
class BankAccount {
    private var balance: Double = 0.0
    var accountNumber: String
    
    fun deposit(amount: Double) {
        this.balance += amount  // OK - private access within class
    }
    
    fun getBalance(): Double {
        return this.balance
    }
}
```

### Static Variables

Static variables belong to the class rather than instances:

```amlang
class Counter {
    static var totalCount: Int = 0
    var instanceId: Int = 0
    
    // Initialization method to set up instance
    fun initialize() {
        totalCount++           // Access static variable
        this.instanceId = totalCount
    }
    
    static fun getTotalCount(): Int {
        return totalCount      // OK - static method accessing static variable
        // return instanceId   // Error - can't access instance var from static
    }
}
```

## Variable Initialization

### Class Field Initialization

Class fields can be initialized in various ways:

```amlang
```amlang
class Person(var name: String, var age: Int) {
    // name and age are automatically initialized as fields
}
```

### Initialization Methods

For complex initialization logic, use initialization methods:

```amlang
class ComplexObject {
    var name: String = ""
    var data: String[] = []
    
    fun initializeWithData(name: String, dataSize: Int) {
        this.name = name
        this.data = new String[dataSize]
        // Additional initialization logic
    }
}
```

### Class Parameter Declaration

Fields can be declared directly in the class parameters:

```amlang
class Person(var name: String, var age: Int) {
    // name and age are automatically declared as fields
}

class Point(private var x: Int, private var y: Int) {
    // private fields declared in class parameters
}
```

## Variable Naming Conventions

### Naming Rules

- Must start with letter (a-z, A-Z) or underscore (_)
- Can contain letters, digits, and underscores
- Case-sensitive
- Cannot be keywords

```amlang
// Valid names
var userName: String
var _privateField: Int
var count123: Int
var MAX_SIZE: Int

// Invalid names
// var 123count: Int      // Starts with digit
// var user-name: String  // Contains hyphen
// var class: String      // Reserved keyword
```

### Naming Conventions

Follow these conventions for consistency:

```amlang
// camelCase for variables and functions
var firstName: String
var isReady: Bool
fun calculateTotal(): Double

// PascalCase for classes and interfaces
class PersonManager
interface Drawable

// SCREAMING_SNAKE_CASE for constants
const var MAX_RETRY_COUNT = 3
const var DEFAULT_TIMEOUT = 5000

// underscore prefix for private fields
class Example {
    private var _internalState: Int
}
```

## Variable Examples

### Basic Variable Usage

```amlang
namespace VariableExamples {
    class VariableDemo(var name: String) {
        // Class fields
        private var _id: Int = generateId()
        static var instanceCount: Int = 0
        
        // Instance initialization
        fun initializeInstance() {
            instanceCount++
        }
        
        fun demonstrateVariables() {
            // Local variables
            var message = "Hello, ${this.name}!"
            var numbers = new Int[] {1, 2, 3, 4, 5}
            
            // Constants
            const var MAX_ATTEMPTS = 3
            const var RETRY_DELAY = 1000
            
            // Nullable variables
            var optionalInt: Int? = null
            var result: Int? = tryOperation()
            
            // Type inference
            var count = 0              // Int
            var isActive = true        // Bool
            var timestamp = System.currentTimeMillis() // Long
            
            // Safe null handling
            result?.toString()?.print()
            
            if (optional != null) {
                optional.print()
            }
        }
        
        private fun tryOperation(): Int? {
            // Implementation that might return null
            return null
        }
        
        private fun generateId(): Int {
            return instanceCount + 1
        }
    }
}
```

### Variable Lifecycle

```amlang
class LifecycleExample {
    var field: String = "I live with the object"
    
    fun method() {
        var local = "I live in this method"
        
        if (true) {
            var block = "I live in this block"
            field.print()  // OK - field accessible
            local.print()  // OK - local accessible
        }
        
        field.print()      // OK - field still accessible
        local.print()      // OK - local still accessible
        // block.print()   // Error - block variable out of scope
    }
}
```

## Memory Management

### Automatic Reference Counting

Am Lang uses automatic reference counting for memory management:

```amlang
class ResourceHolder {
    private var resource: Resource = new Resource()  // Reference count = 1
    
    fun shareResource(): Resource {
        return this.resource            // Reference count = 2
    }
    
    // When object is destroyed, reference count decreases
    // When reference count reaches 0, resource is deallocated
}
```

### Variable Lifetime

- **Local variables**: Destroyed when leaving scope
- **Instance fields**: Live as long as the object instance
- **Static fields**: Live for the program duration
- **Parameters**: Destroyed when function returns

## Best Practices

### 1. Use Meaningful Names
```amlang
// Good
var userAccountBalance: Double
var isEmailVerified: Bool

// Poor
var bal: Double
var flag: Bool
```

### 2. Prefer Constants When Possible
```amlang
// Good
const var TAX_RATE = 0.08
const var COMPANY_NAME = "Acme Corp"

// Less ideal if values don't change
var taxRate = 0.08
var companyName = "Acme Corp"
```

### 3. Initialize Variables Close to Use
```amlang
// Good
fun processUser(userId: Int) {
    var user = findUser(userId)
    var profile = user.getProfile()
    // use profile immediately
}

// Less ideal
fun processUser(userId: Int) {
    var user: User
    var profile: Profile
    // ... lots of other code ...
    user = findUser(userId)
    profile = user.getProfile()
}
```

### 4. Use Type Inference When Clear
```amlang
// Good - type is obvious
var message = "Hello, World!"
var count = 0

// Good - type annotation for clarity
var callback: (String) -> Bool
var data: List<Person>
```

### 5. Handle Nullable Types Safely
```amlang
// Good
var count: Int? = getCount()
count?.toString()

if (count != null) {
    (count + 1).toString().print()
}

// Dangerous (avoid if possible)
// name!!.print()  // Force unwrap - may crash
```

## Next Steps

- Learn about [Classes and Objects](./06-classes-objects.md)
- Explore [Functions](./10-functions.md)
- Understand [Access Modifiers](./09-access-modifiers.md)