# Classes and Objects

This document covers class definitions, object creation, and object-oriented programming features in Am Lang.

## Class Declaration

### Basic Class

```amlang
class Person {
    // class body
}
```

### Class with Constructor Parameters

```amlang
class Person(var name: String, var age: Int) {
    // Constructor parameters automatically become fields
}
```

### Class with Fields and Methods

```amlang
class Person {
    var name: String
    var age: Int
    
    constructor(name: String, age: Int) {
        this.name = name
        this.age = age
    }
    
    fun greet(): String {
        return "Hello, I'm ${name} and I'm ${age} years old"
    }
}
```

## Object Creation

### Creating Instances

Use the `new` keyword to create objects:

```amlang
var person = new Person("Alice", 25)
var emptyPerson = new Person()
```

### Constructor Calls

```amlang
class Rectangle {
    var width: Int
    var height: Int
    
    constructor(width: Int, height: Int) {
        this.width = width
        this.height = height
    }
    
    constructor(size: Int) {
        this.width = size
        this.height = size
    }
}

var rect1 = new Rectangle(10, 20)  // Two-parameter constructor
var square = new Rectangle(15)     // Single-parameter constructor
```

## Class Members

### Fields (Properties)

```amlang
class BankAccount {
    var accountNumber: String           // Public field
    private var balance: Double         // Private field
    static var totalAccounts: Int = 0   // Static field
    
    constructor(accountNumber: String) {
        this.accountNumber = accountNumber
        this.balance = 0.0
        totalAccounts++
    }
}
```

### Methods

```amlang
class Calculator {
    fun add(a: Int, b: Int): Int {
        return a + b
    }
    
    fun multiply(a: Int, b: Int): Int {
        return a * b
    }
    
    static fun pi(): Double {
        return 3.14159
    }
}
```

### Method Calls

```amlang
var calc = new Calculator()
var sum = calc.add(5, 3)           // Instance method
var product = calc.multiply(4, 7)   // Instance method
var piValue = Calculator.pi()       // Static method
```

## Access Modifiers

### Private Members

```amlang
class Person {
    private var ssn: String           // Private field
    var name: String                  // Public field
    
    constructor(name: String, ssn: String) {
        this.name = name
        this.ssn = ssn
    }
    
    private fun validateSSN(): Bool { // Private method
        return ssn.length() == 9
    }
    
    fun isValid(): Bool {             // Public method
        return validateSSN()          // Can call private method
    }
}
```

### Static Members

```amlang
class MathUtils {
    static var PI: Double = 3.14159
    
    static fun max(a: Int, b: Int): Int {
        return if (a > b) a else b
    }
    
    static fun min(a: Int, b: Int): Int {
        return if (a < b) a else b
    }
}

// Usage
var maxValue = MathUtils.max(10, 20)
var piValue = MathUtils.PI
```

## Constructor Patterns

### Primary Constructor

The most common pattern with parameters directly in the class declaration:

```amlang
class Point(var x: Int, var y: Int) {
    fun distanceFromOrigin(): Double {
        return Math.sqrt((x * x + y * y).toDouble())
    }
}
```

### Multiple Constructors

```amlang
class Person {
    var name: String
    var age: Int
    var email: String
    
    constructor(name: String, age: Int) {
        this.name = name
        this.age = age
        this.email = ""
    }
    
    constructor(name: String, age: Int, email: String) {
        this.name = name
        this.age = age
        this.email = email
    }
}
```

### Constructor with Validation

```amlang
class BankAccount {
    var accountNumber: String
    private var balance: Double
    
    constructor(accountNumber: String, initialBalance: Double) {
        if (accountNumber.length() < 5) {
            throw new Exception("Account number too short")
        }
        if (initialBalance < 0) {
            throw new Exception("Initial balance cannot be negative")
        }
        
        this.accountNumber = accountNumber
        this.balance = initialBalance
    }
}
```

## Object References

### Reference Assignment

```amlang
var person1 = new Person("Alice", 25)
var person2 = person1              // Both variables reference same object

person1.name = "Bob"
person2.name.print()               // Prints "Bob" - same object
```

### Null References

```amlang
var person1 = new Person("Alice", 25)
var person2 = person1              // Both variables reference same object

person1.name = "Bob"
person2.name.print()               // Prints "Bob" - same object

// Note: Object types cannot be made nullable with the ? operator
// Only primitive types support nullable syntax like Int?, Bool?, UShort?
```

## Method Overloading

Methods can be overloaded with different parameter lists:

```amlang
class Printer {
    fun print(message: String) {
        message.print()
    }
    
    fun print(number: Int) {
        number.toString().print()
    }
    
    fun print(flag: Bool) {
        (if (flag) "true" else "false").print()
    }
}

var printer = new Printer()
printer.print("Hello")    // Calls String version
printer.print(42)         // Calls Int version
printer.print(true)       // Calls Bool version
```

## The `this` Keyword

### Referencing Current Instance

```amlang
class Person {
    var name: String
    
    constructor(name: String) {
        this.name = name           // Distinguish parameter from field
    }
    
    fun introduce(): String {
        return "My name is ${this.name}"
    }
    
    fun compareTo(other: Person): Bool {
        return this.name == other.name
    }
}
```

### Method Chaining

```amlang
class Builder {
    private var value: String = ""
    
    fun append(text: String): Builder {
        this.value += text
        return this               // Return self for chaining
    }
    
    fun build(): String {
        return this.value
    }
}

var result = new Builder()
    .append("Hello")
    .append(" ")
    .append("World")
    .build()
```

## Object Lifecycle

### Object Creation

1. Memory allocated
2. Constructor called
3. Object initialized
4. Reference returned

```amlang
var person = new Person("Alice", 25)  // All steps happen here
```

### Object Destruction

Am Lang uses automatic reference counting:

```amlang
fun createAndUse() {
    var person = new Person("Alice", 25)  // Reference count = 1
    var another = person                  // Reference count = 2
    
    // When function ends:
    // 'another' goes out of scope       -> Reference count = 1
    // 'person' goes out of scope        -> Reference count = 0
    // Object is automatically destroyed
}
```

## Class Examples

### Complete Person Class

```amlang
namespace Examples {
    class Person {
        private var _name: String
        private var _age: Int
        private var _email: String
        
        static var totalPeople: Int = 0
        
        constructor(name: String, age: Int) {
            this._name = name
            this._age = age
            this._email = ""
            totalPeople++
        }
        
        constructor(name: String, age: Int, email: String) {
            this._name = name
            this._age = age
            this._email = email
            totalPeople++
        }
        
        // Getters
        fun getName(): String {
            return this._name
        }
        
        fun getAge(): Int {
            return this._age
        }
        
        fun getEmail(): String {
            return this._email
        }
        
        // Setters
        fun setEmail(email: String) {
            if (this.isValidEmail(email)) {
                this._email = email
            }
        }
        
        // Business methods
        fun greet(): String {
            return "Hello, I'm ${this._name}"
        }
        
        fun haveBirthday() {
            this._age++
        }
        
        fun isAdult(): Bool {
            return this._age >= 18
        }
        
        // Private helper methods
        private fun isValidEmail(email: String): Bool {
            return email.contains("@")
        }
        
        // Static methods
        static fun getTotalPeople(): Int {
            return totalPeople
        }
        
        // Override Object methods
        override fun toString(): String {
            return "Person(name=${this._name}, age=${this._age})"
        }
    }
}
```

### Bank Account Example

```amlang
namespace Banking {
    class BankAccount {
        private var _accountNumber: String
        private var _balance: Double
        private var _owner: String
        
        static var nextAccountNumber: Int = 1000
        
        constructor(owner: String, initialBalance: Double) {
            this._owner = owner
            this._balance = initialBalance
            this._accountNumber = "ACC" + (nextAccountNumber++).toString()
        }
        
        fun deposit(amount: Double): Bool {
            if (amount > 0) {
                this._balance += amount
                return true
            }
            return false
        }
        
        fun withdraw(amount: Double): Bool {
            if (amount > 0 && amount <= this._balance) {
                this._balance -= amount
                return true
            }
            return false
        }
        
        fun getBalance(): Double {
            return this._balance
        }
        
        fun getAccountNumber(): String {
            return this._accountNumber
        }
        
        fun getOwner(): String {
            return this._owner
        }
        
        fun transfer(target: BankAccount, amount: Double): Bool {
            if (this.withdraw(amount)) {
                if (target.deposit(amount)) {
                    return true
                } else {
                    // Rollback if target deposit fails
                    this.deposit(amount)
                }
            }
            return false
        }
        
        override fun toString(): String {
            return "Account ${this._accountNumber} (${this._owner}): $${this._balance}"
        }
    }
}
```

### Usage Example

```amlang
namespace BankingDemo {
    class Main {
        static fun main() {
            // Create accounts
            var aliceAccount = new BankAccount("Alice", 1000.0)
            var bobAccount = new BankAccount("Bob", 500.0)
            
            // Print initial balances
            aliceAccount.toString().println()
            bobAccount.toString().println()
            
            // Perform operations
            aliceAccount.deposit(200.0)
            bobAccount.withdraw(100.0)
            
            // Transfer money
            if (aliceAccount.transfer(bobAccount, 300.0)) {
                "Transfer successful".println()
            } else {
                "Transfer failed".println()
            }
            
            // Print final balances
            aliceAccount.toString().println()
            bobAccount.toString().println()
            
            // Static method call
            var total = Person.getTotalPeople()
            "Total people created: ${total}".println()
        }
    }
}
```

## Best Practices

### 1. Encapsulation
```amlang
// Good - private fields with public methods
class Person {
    private var _age: Int
    
    fun getAge(): Int {
        return this._age
    }
    
    fun setAge(age: Int) {
        if (age >= 0 && age <= 150) {
            this._age = age
        }
    }
}

// Poor - public fields
class Person {
    var age: Int  // No validation possible
}
```

### 2. Constructor Validation
```amlang
class Rectangle {
    private var _width: Int
    private var _height: Int
    
    constructor(width: Int, height: Int) {
        if (width <= 0 || height <= 0) {
            throw new Exception("Dimensions must be positive")
        }
        this._width = width
        this._height = height
    }
}
```

### 3. Meaningful Method Names
```amlang
// Good
fun calculateTotalPrice(): Double
fun isEmailValid(): Bool
fun processUserRegistration()

// Poor
fun calc(): Double
fun check(): Bool
fun process()
```

### 4. Single Responsibility
```amlang
// Good - focused responsibility
class EmailValidator {
    fun isValid(email: String): Bool {
        return email.contains("@") && email.contains(".")
    }
}

class User {
    var email: String
    
    fun setEmail(email: String) {
        var validator = new EmailValidator()
        if (validator.isValid(email)) {
            this.email = email
        }
    }
}

// Poor - multiple responsibilities
class User {
    var email: String
    
    fun setEmail(email: String) {
        // Email validation logic mixed with user logic
        if (email.contains("@") && email.contains(".")) {
            this.email = email
        }
    }
    
    fun sendWelcomeEmail() {
        // Email sending logic in user class
    }
}
```

## Next Steps

- Learn about [Inheritance](./07-inheritance.md)
- Explore [Interfaces](./08-interfaces.md)
- Understand [Functions](./10-functions.md)