# Examples

This document provides comprehensive examples of Am Lang programming, from basic concepts to advanced patterns.

## Basic Examples

### 1. Hello World Variations

#### Simple Hello World
```amlang
namespace BasicExamples {
    class HelloWorld {
        static fun main() {
            "Hello, World!".println()
        }
    }
}
```

#### Interactive Hello World
```amlang
namespace InteractiveExamples {
    class InteractiveHello {
        static fun main() {
            "What's your name? ".print()
            // Note: Input handling would require native integration
            var name = "User"  // Placeholder
            "Hello, ${name}! Welcome to Am Lang!".println()
        }
    }
}
```

### 2. Variables and Basic Operations

```amlang
namespace VariableExamples {
    class BasicOperations {
        static fun main() {
            // Integer operations
            var a = 10
            var b = 5
            
            "Addition: ${a} + ${b} = ${a + b}".println()
            "Subtraction: ${a} - ${b} = ${a - b}".println()
            "Multiplication: ${a} * ${b} = ${a * b}".println()
            "Division: ${a} / ${b} = ${a / b}".println()
            "Modulo: ${a} % ${b} = ${a % b}".println()
            
            // String operations
            var firstName = "John"
            var lastName = "Doe"
            var fullName = firstName + " " + lastName
            "Full name: ${fullName}".println()
            
            // Boolean operations
            var isAdult = true
            var hasLicense = false
            var canDrive = isAdult && hasLicense
            "Can drive: ${canDrive}".println()
        }
    }
}
```

### 3. String Interpolation Examples

#### Basic Variable Interpolation
```amlang
namespace StringInterpolationExamples {
    class BasicInterpolation {
        static fun main() {
            var name = "Alice"
            var age = 25
            var city = "New York"
            
            // Simple variable interpolation
            "Hello, my name is $name".println()
            "I am $age years old".println()
            "I live in $city".println()
            
            // Mixed content
            "User: $name, Age: $age, Location: $city".println()
        }
    }
}
```

#### Expression Interpolation
```amlang
namespace StringInterpolationExamples {
    class ExpressionInterpolation {
        static fun main() {
            var x = 10
            var y = 20
            var price = 99.99
            var quantity = 3
            
            // Mathematical expressions
            "Sum: ${x + y}".println()
            "Product: ${x * y}".println()
            "Average: ${(x + y) / 2}".println()
            
            // Function calls in expressions
            "Absolute difference: ${Math.abs(x - y)}".println()
            
            // Complex expressions
            "Total cost: $${price * quantity}".println()
            "Discount: $${(price * quantity) * 0.1}".println()
            "Final amount: $${(price * quantity) * 0.9}".println()
        }
    }
}
```

#### Object Interpolation with toString()
```amlang
namespace StringInterpolationExamples {
    class Person(var name: String, var age: Int) {
        
        fun toString(): String {
            return "Person(name=${name}, age=${age})"
        }
    }
    
    class Product(var name: String, var price: Double) {
        
        fun toString(): String {
            return "${name} - $${price}"
        }
    }
    
    class ObjectInterpolation {
        static fun main() {
            var person = new Person("Bob", 30)
            var product = new Product("Laptop", 999.99)
            
            // Object interpolation calls toString() automatically
            "Customer: $person".println()
            "Product: $product".println()
            
            // Complex object expressions
            "Order: ${person.name} purchased ${product.name}".println()
            "Details: $person bought $product".println()
            
            // Nested interpolation
            "Summary: ${person.toString()} ordered ${product.toString()}".println()
        }
    }
}
```

### 4. Control Flow Examples

#### If-Else Statements
```amlang
namespace ControlFlow {
    class ConditionalExample {
        static fun main() {
            var age = 20
            var hasPermit = true
            
            if (age >= 18) {
                "You are an adult".println()
                
                if (hasPermit) {
                    "You can drive".println()
                } else {
                    "You need a driving permit".println()
                }
            } else {
                "You are a minor".println()
                var yearsToAdult = 18 - age
                "You need to wait ${yearsToAdult} more years".println()
            }
        }
    }
}
```

#### Loops
```amlang
namespace LoopExamples {
    class LoopDemo {
        static fun main() {
            "Counting up:".println()
            for (i in 1 to 5) {
                "Count: ${i}".println()
            }
            
            "Counting down:".println()
            for (i in 5 to 1) {
                "Countdown: ${i}".println()
            }
        }
    }
}
```

## Object-Oriented Examples

### 4. Simple Class Example

```amlang
namespace OOPExamples {
    class Student(private var _name: String, private var _age: Int, private var _grade: String) {
        
        fun getName(): String {
            return this._name
        }
        
        fun getAge(): Int {
            return this._age
        }
        
        fun getGrade(): String {
            return this._grade
        }
        
        fun introduce(): String {
            return "Hi, I'm ${this._name}, ${this._age} years old, in grade ${this._grade}"
        }
        
        fun haveBirthday() {
            this._age++
            "Happy birthday! Now ${this._age} years old".println()
        }
        
        fun promoteGrade(newGrade: String) {
            this._grade = newGrade
            "Congratulations! Promoted to grade ${this._grade}".println()
        }
    }
    
    class Main {
        static fun main() {
            var student = new Student("Alice", 16, "10th")
            
            student.introduce().println()
            student.haveBirthday()
            student.promoteGrade("11th")
        }
    }
}
```

### 5. Inheritance Example

```amlang
namespace InheritanceExample {
    class Animal(protected var name: String, protected var species: String) {
        
        fun getName(): String {
            return this.name
        }
        
        fun getSpecies(): String {
            return this.species
        }
        
        fun makeSound(): String {
            return "Some generic animal sound"
        }
        
        fun introduce(): String {
            return "I'm ${this.name}, a ${this.species}"
        }
    }
    
    class Dog : Animal {
        private var breed: String
        
        // Note: AmLang initialization patterns for inheritance may differ
        // This example shows conceptual inheritance structure
        fun initializeDog(name: String, breed: String) {
            // Initialize with super call equivalent: super(name, "Dog")
            this.breed = breed
        }
        
        override fun makeSound(): String {
            return "Woof! Woof!"
        }
        
        fun getBreed(): String {
            return this.breed
        }
        
        fun wagTail() {
            "${this.name} is wagging their tail happily!".println()
        }
    }
    
    class Cat : Animal {
        private var isIndoor: Bool
        
        // Note: AmLang initialization patterns for inheritance may differ
        // This example shows conceptual inheritance structure
        fun initializeCat(name: String, isIndoor: Bool) {
            // Initialize with super call equivalent: super(name, "Cat")
            this.isIndoor = isIndoor
        }
        
        override fun makeSound(): String {
            return "Meow!"
        }
        
        fun purr() {
            "${this.name} is purring contentedly".println()
        }
        
        fun getLifestyle(): String {
            return if (this.isIndoor) "indoor" else "outdoor"
        }
    }
    
    class Main {
        static fun main() {
            var dog = new Dog("Buddy", "Golden Retriever")
            var cat = new Cat("Whiskers", true)
            
            dog.introduce().println()
            dog.makeSound().println()
            dog.wagTail()
            
            cat.introduce().println()
            cat.makeSound().println()
            cat.purr()
            "Lifestyle: ${cat.getLifestyle()}".println()
        }
    }
}
```

### 6. Interface Example

```amlang
namespace InterfaceExample {
    interface Drawable {
        fun draw()
        fun getArea(): Double
    }
    
    interface Movable {
        fun move(x: Int, y: Int)
        fun getPosition(): String
    }
    
    class Circle : Drawable, Movable {
        private var radius: Double
        private var x: Int = 0
        private var y: Int = 0
        
        // Note: AmLang initialization patterns may differ for interface implementations
        fun initializeCircle(radius: Double) {
            this.radius = radius
        }
        
        override fun draw() {
            "Drawing circle with radius ${this.radius} at (${this.x}, ${this.y})".println()
        }
        
        override fun getArea(): Double {
            return 3.14159 * this.radius * this.radius
        }
        
        override fun move(x: Int, y: Int) {
            this.x = x
            this.y = y
        }
        
        override fun getPosition(): String {
            return "(${this.x}, ${this.y})"
        }
    }
    
    class Rectangle : Drawable, Movable {
        private var width: Double
        private var height: Double
        private var x: Int = 0
        private var y: Int = 0
        
        // Note: AmLang initialization patterns may differ for interface implementations
        fun initializeRectangle(width: Double, height: Double) {
            this.width = width
            this.height = height
        }
        
        override fun draw() {
            "Drawing rectangle ${this.width}x${this.height} at (${this.x}, ${this.y})".println()
        }
        
        override fun getArea(): Double {
            return this.width * this.height
        }
        
        override fun move(x: Int, y: Int) {
            this.x = x
            this.y = y
        }
        
        override fun getPosition(): String {
            return "(${this.x}, ${this.y})"
        }
    }
    
    class ShapeManager {
        fun processShape(shape: Drawable) {
            shape.draw()
            "Area: ${shape.getArea()}".println()
            
            if (shape is Movable) {
                var movableShape: Movable = shape as Movable
                movableShape.move(10, 20)
                "Moved to: ${movableShape.getPosition()}".println()
            }
        }
    }
    
    class Main {
        static fun main() {
            var circle = new Circle(5.0)
            var rectangle = new Rectangle(10.0, 8.0)
            var manager = new ShapeManager()
            
            "Processing Circle:".println()
            manager.processShape(circle)
            
            "Processing Rectangle:".println()
            manager.processShape(rectangle)
        }
    }
}
```

## Advanced Examples

### 7. Calculator with Error Handling

```amlang
namespace CalculatorExample {
    class Calculator {
        fun add(a: Double, b: Double): Double {
            return a + b
        }
        
        fun subtract(a: Double, b: Double): Double {
            return a - b
        }
        
        fun multiply(a: Double, b: Double): Double {
            return a * b
        }
        
        fun divide(a: Double, b: Double): Double? {
            if (b == 0.0) {
                "Error: Division by zero".println()
                return null
            }
            return a / b
        }
        
        fun power(base: Double, exponent: Int): Double {
            if (exponent == 0) {
                return 1.0
            }
            
            var result = 1.0
            var exp = if (exponent < 0) -exponent else exponent
            
            for (i in 1 to exp) {
                result *= base
            }
            
            return if (exponent < 0) 1.0 / result else result
        }
        
        fun factorial(n: Int): Long? {
            if (n < 0) {
                "Error: Factorial not defined for negative numbers".println()
                return null
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
    }
    
    class CalculatorDemo {
        static fun main() {
            var calc = new Calculator()
            
            // Basic operations
            "=== Basic Operations ===".println()
            "10 + 5 = ${calc.add(10.0, 5.0)}".println()
            "10 - 5 = ${calc.subtract(10.0, 5.0)}".println()
            "10 * 5 = ${calc.multiply(10.0, 5.0)}".println()
            
            var divResult = calc.divide(10.0, 5.0)
            if (divResult != null) {
                "10 / 5 = ${divResult}".println()
            }
            
            // Error case
            calc.divide(10.0, 0.0)
            
            // Advanced operations
            "=== Advanced Operations ===".println()
            "2^3 = ${calc.power(2.0, 3)}".println()
            "5! = ${calc.factorial(5)}".println()
            
            // Error case
            calc.factorial(-5)
        }
    }
}
```

### 8. Banking System Example

```amlang
namespace BankingSystem {
    class BankAccount {
        private var _accountNumber: String = ""
        private var _balance: Double = 0.0
        private var _ownerName: String = ""
        private var _isActive: Bool = false
        
        static var nextAccountNumber: Int = 1000
        
        static fun create(ownerName: String, initialDeposit: Double): BankAccount {
            var account = new BankAccount()
            account._ownerName = ownerName
            account._balance = initialDeposit
            account._accountNumber = "ACC" + (nextAccountNumber++).toString()
            account._isActive = true
            return account
        }
        
        fun getAccountNumber(): String {
            return this._accountNumber
        }
        
        fun getBalance(): Double {
            return this._balance
        }
        
        fun getOwnerName(): String {
            return this._ownerName
        }
        
        fun isActive(): Bool {
            return this._isActive
        }
        
        fun deposit(amount: Double): Bool {
            if (!this._isActive) {
                "Error: Account is inactive".println()
                return false
            }
            
            if (amount <= 0) {
                "Error: Deposit amount must be positive".println()
                return false
            }
            
            this._balance += amount
            "Deposited $${amount}. New balance: $${this._balance}".println()
            return true
        }
        
        fun withdraw(amount: Double): Bool {
            if (!this._isActive) {
                "Error: Account is inactive".println()
                return false
            }
            
            if (amount <= 0) {
                "Error: Withdrawal amount must be positive".println()
                return false
            }
            
            if (amount > this._balance) {
                "Error: Insufficient funds. Balance: $${this._balance}".println()
                return false
            }
            
            this._balance -= amount
            "Withdrew $${amount}. New balance: $${this._balance}".println()
            return true
        }
        
        fun transfer(targetAccount: BankAccount, amount: Double): Bool {
            if (this.withdraw(amount)) {
                if (targetAccount.deposit(amount)) {
                    "Transfer of $${amount} to ${targetAccount.getAccountNumber()} successful".println()
                    return true
                } else {
                    // Rollback
                    this.deposit(amount)
                    "Transfer failed - rolling back".println()
                }
            }
            return false
        }
        
        fun closeAccount() {
            this._isActive = false
            "Account ${this._accountNumber} has been closed".println()
        }
        
        fun getAccountSummary(): String {
            var status = if (this._isActive) "Active" else "Closed"
            return "Account: ${this._accountNumber}\nOwner: ${this._ownerName}\nBalance: $${this._balance}\nStatus: ${status}"
        }
    }
    
    class Bank(private var maxAccounts: Int) {
        private var accounts: BankAccount[]
        private var accountCount: Int = 0
        
        // Initialize the accounts array after construction
        fun initialize() {
            this.accounts = new BankAccount[maxAccounts]
        }
        
        fun createAccount(ownerName: String, initialDeposit: Double): BankAccount {
            if (this.accountCount >= this.accounts.length) {
                "Error: Bank has reached maximum account capacity".println()
                return null
            }
            
            var account = BankAccount.create(ownerName, initialDeposit)
            this.accounts[this.accountCount] = account
            this.accountCount++
            
            "Account created successfully: ${account.getAccountNumber()}".println()
            return account
        }
        
        fun findAccount(accountNumber: String): BankAccount {
            for (i in 0 to this.accountCount - 1) {
                if (this.accounts[i].getAccountNumber() == accountNumber) {
                    return this.accounts[i]
                }
            }
            return null
        }
        
        fun getTotalAssets(): Double {
            var total = 0.0
            for (i in 0 to this.accountCount - 1) {
                if (this.accounts[i].isActive()) {
                    total += this.accounts[i].getBalance()
                }
            }
            return total
        }
        
        fun printAllAccounts() {
            "=== Bank Account Summary ===".println()
            for (i in 0 to this.accountCount - 1) {
                this.accounts[i].getAccountSummary().println()
                "".println()
            }
            "Total Assets: $${this.getTotalAssets()}".println()
        }
    }
    
    class BankingDemo {
        static fun main() {
            var bank = new Bank(100)
            bank.initialize()
            
            // Create accounts
            var aliceAccount = bank.createAccount("Alice Johnson", 1000.0)
            var bobAccount = bank.createAccount("Bob Smith", 500.0)
            var charlieAccount = bank.createAccount("Charlie Brown", 750.0)
            
            if (aliceAccount != null && bobAccount != null && charlieAccount != null) {
                // Perform transactions
                "=== Initial State ===".println()
                bank.printAllAccounts()
                
                "=== Performing Transactions ===".println()
                aliceAccount.deposit(200.0)
                bobAccount.withdraw(100.0)
                charlieAccount.transfer(aliceAccount, 250.0)
                
                "=== Final State ===".println()
                bank.printAllAccounts()
                
                // Close an account
                bobAccount.closeAccount()
                
                "=== After Closing Bob's Account ===".println()
                bank.printAllAccounts()
            }
        }
    }
}
```

### 9. Threading Example with Shared Resource

```amlang
namespace ThreadingExamples {
    class SharedCounter {
        private var count: Int = 0
        
        // Note: In real implementation, this would need synchronization
        fun increment() {
            this.count++
        }
        
        fun decrement() {
            this.count--
        }
        
        fun getValue(): Int {
            return this.count
        }
    }
    
    class CounterWorker : Runnable {
        private var counter: SharedCounter
        private var iterations: Int
        private var increment: Bool
        private var workerId: String
        
        // Note: AmLang initialization patterns for Runnable may differ
        fun initializeWorker(counter: SharedCounter, iterations: Int, increment: Bool, workerId: String) {
            this.counter = counter
            this.iterations = iterations
            this.increment = increment
            this.workerId = workerId
        }
        
        override fun run() {
            "${this.workerId} started".println()
            
            for (i in 1 to this.iterations) {
                if (this.increment) {
                    this.counter.increment()
                    "${this.workerId}: Incremented to ${this.counter.getValue()}".println()
                } else {
                    this.counter.decrement()
                    "${this.workerId}: Decremented to ${this.counter.getValue()}".println()
                }
                
                Thread.sleep(100)  // Small delay
            }
            
            "${this.workerId} finished".println()
        }
    }
    
    class ProducerConsumerExample {
        class Buffer<T>(private var maxSize: Int) {
            private var items: T[] = new T[maxSize]
            private var count: Int = 0
            
            fun put(item: T): Bool {
                if (this.count < this.maxSize) {
                    this.items[this.count] = item
                    this.count++
                    return true
                }
                return false
            }
            
            fun take(): T? {
                if (this.count > 0) {
                    this.count--
                    return this.items[this.count]
                }
                return null
            }
            
            fun isEmpty(): Bool {
                return this.count == 0
            }
            
            fun isFull(): Bool {
                return this.count >= this.maxSize
            }
        }
        
        class Producer : Runnable {
            private var buffer: Buffer<String>
            private var itemCount: Int
            private var producerId: String
            
            // Note: AmLang initialization patterns for Runnable may differ
            fun initializeProducer(buffer: Buffer<String>, itemCount: Int, producerId: String) {
                this.buffer = buffer
                this.itemCount = itemCount
                this.producerId = producerId
            }
            
            override fun run() {
                "${this.producerId} started producing".println()
                
                for (i in 1 to this.itemCount) {
                    var item = "${this.producerId}-Item-${i}"
                    
                    while (!this.buffer.put(item)) {
                        Thread.sleep(50)  // Wait if buffer full
                    }
                    
                    "${this.producerId} produced: ${item}".println()
                    Thread.sleep(200)
                }
                
                "${this.producerId} finished producing".println()
            }
        }
        
        class Consumer : Runnable {
            private var buffer: Buffer<String>
            private var consumerId: String
            private var running: Bool = true
            
            // Note: AmLang initialization patterns for Runnable may differ
            fun initializeConsumer(buffer: Buffer<String>, consumerId: String) {
                this.buffer = buffer
                this.consumerId = consumerId
            }
            
            override fun run() {
                "${this.consumerId} started consuming".println()
                
                var consumedCount = 0
                while (this.running && consumedCount < 10) {
                    var item = this.buffer.take()
                    
                    if (item != null) {
                        "${this.consumerId} consumed: ${item}".println()
                        consumedCount++
                        Thread.sleep(300)
                    } else {
                        Thread.sleep(100)  // Wait if buffer empty
                    }
                }
                
                "${this.consumerId} finished consuming".println()
            }
        }
    }
    
    class ThreadingDemo {
        static fun main() {
            "=== Shared Counter Example ===".println()
            sharedCounterDemo()
            
            "=== Producer-Consumer Example ===".println()
            producerConsumerDemo()
        }
        
        static fun sharedCounterDemo() {
            var counter = new SharedCounter()
            
            var incrementer = new CounterWorker(counter, 5, true, "Incrementer")
            var decrementer = new CounterWorker(counter, 3, false, "Decrementer")
            
            var thread1 = new Thread(incrementer)
            var thread2 = new Thread(decrementer)
            
            thread1.start()
            thread2.start()
            
            thread1.join()
            thread2.join()
            
            "Final counter value: ${counter.getValue()}".println()
        }
        
        static fun producerConsumerDemo() {
            var buffer = new ProducerConsumerExample.Buffer<String>(3)
            
            var producer1 = new ProducerConsumerExample.Producer(buffer, 5, "Producer-1")
            var producer2 = new ProducerConsumerExample.Producer(buffer, 3, "Producer-2")
            var consumer1 = new ProducerConsumerExample.Consumer(buffer, "Consumer-1")
            var consumer2 = new ProducerConsumerExample.Consumer(buffer, "Consumer-2")
            
            var prodThread1 = new Thread(producer1)
            var prodThread2 = new Thread(producer2)
            var consThread1 = new Thread(consumer1)
            var consThread2 = new Thread(consumer2)
            
            consThread1.start()
            consThread2.start()
            prodThread1.start()
            prodThread2.start()
            
            prodThread1.join()
            prodThread2.join()
            
            // Let consumers finish remaining items
            Thread.sleep(2000)
            
            "Producer-Consumer demo completed".println()
        }
    }
}
```

### 10. Game Example - Simple RPG Characters

```amlang
namespace GameExample {
    class Character(protected var name: String, protected var health: Int, protected var attack: Int, protected var defense: Int) {
        protected var maxHealth: Int = health
        protected var level: Int = 1
        
        fun getName(): String {
            return this.name
        }
        
        fun getHealth(): Int {
            return this.health
        }
        
        fun getMaxHealth(): Int {
            return this.maxHealth
        }
        
        fun isAlive(): Bool {
            return this.health > 0
        }
        
        fun takeDamage(damage: Int) {
            var actualDamage = damage - this.defense
            if (actualDamage < 0) {
                actualDamage = 0
            }
            
            this.health -= actualDamage
            if (this.health < 0) {
                this.health = 0
            }
            
            "${this.name} takes ${actualDamage} damage! Health: ${this.health}/${this.maxHealth}".println()
            
            if (!this.isAlive()) {
                "${this.name} has been defeated!".println()
            }
        }
        
        fun heal(amount: Int) {
            this.health += amount
            if (this.health > this.maxHealth) {
                this.health = this.maxHealth
            }
            
            "${this.name} heals for ${amount}! Health: ${this.health}/${this.maxHealth}".println()
        }
        
        fun attackTarget(target: Character) {
            if (!this.isAlive()) {
                "${this.name} cannot attack - they are defeated!".println()
                return
            }
            
            "${this.name} attacks ${target.getName()}!".println()
            target.takeDamage(this.attack)
        }
        
        fun getStats(): String {
            return "${this.name} (Level ${this.level}) - HP: ${this.health}/${this.maxHealth}, ATK: ${this.attack}, DEF: ${this.defense}"
        }
    }
    
    class Warrior : Character {
        private var rage: Int = 0
        
        // Note: AmLang inheritance initialization patterns may differ
        fun initializeWarrior(name: String) {
            // Equivalent to: super(name, 120, 25, 8)
            // Base stats: 120 health, 25 attack, 8 defense
        }
        
        fun useRage() {
            if (this.rage >= 10) {
                this.rage = 0
                return this.attack * 2
            } else {
                "Not enough rage!".println()
                return this.attack
            }
        }
        
        override fun attackTarget(target: Character) {
            if (!this.isAlive()) {
                "${this.name} cannot attack - they are defeated!".println()
                return
            }
            
            this.rage += 2
            "${this.name} (Warrior) attacks ${target.getName()}! Rage: ${this.rage}".println()
            
            var damage = this.attack
            if (this.rage >= 10) {
                damage = this.useRage()
                "${this.name} uses RAGE! Double damage!".println()
            }
            
            target.takeDamage(damage)
        }
    }
    
    class Mage : Character {
        private var mana: Int = 50
        private var maxMana: Int = 50
        
        // Note: AmLang inheritance initialization patterns may differ
        fun initializeMage(name: String) {
            // Equivalent to: super(name, 80, 15, 3)
            // Base stats: 80 health, 15 attack, 3 defense
        }
        
        fun getMana(): Int {
            return this.mana
        }
        
        fun castFireball(target: Character) {
            if (!this.isAlive()) {
                "${this.name} cannot cast - they are defeated!".println()
                return
            }
            
            if (this.mana < 15) {
                "Not enough mana for Fireball!".println()
                return
            }
            
            this.mana -= 15
            "${this.name} casts Fireball at ${target.getName()}! Mana: ${this.mana}/${this.maxMana}".println()
            target.takeDamage(35)
        }
        
        fun castHeal() {
            if (!this.isAlive()) {
                return
            }
            
            if (this.mana < 20) {
                "Not enough mana for Heal!".println()
                return
            }
            
            this.mana -= 20
            "${this.name} casts Heal! Mana: ${this.mana}/${this.maxMana}".println()
            this.heal(40)
        }
        
        fun restoreMana(amount: Int) {
            this.mana += amount
            if (this.mana > this.maxMana) {
                this.mana = this.maxMana
            }
            "${this.name} restores ${amount} mana! Mana: ${this.mana}/${this.maxMana}".println()
        }
    }
    
    class Combat {
        static fun battle(char1: Character, char2: Character) {
            "=== BATTLE BEGINS ===".println()
            "${char1.getStats()}".println()
            "${char2.getStats()}".println()
            "".println()
            
            var round = 1
            while (char1.isAlive() && char2.isAlive()) {
                "--- Round ${round} ---".println()
                
                // Character 1 attacks
                if (char1.isAlive()) {
                    char1.attackTarget(char2)
                }
                
                // Character 2 attacks back (if still alive)
                if (char2.isAlive()) {
                    char2.attackTarget(char1)
                }
                
                "".println()
                round++
                
                // Prevent infinite battles
                if (round > 20) {
                    "Battle timeout - it's a draw!".println()
                    break
                }
            }
            
            if (char1.isAlive() && !char2.isAlive()) {
                "${char1.getName()} wins the battle!".println()
            } else if (!char1.isAlive() && char2.isAlive()) {
                "${char2.getName()} wins the battle!".println()
            } else {
                "The battle ends in a draw!".println()
            }
            
            "=== BATTLE ENDS ===".println()
        }
    }
    
    class GameDemo {
        static fun main() {
            "=== RPG Character Demo ===".println()
            
            var warrior = new Warrior("Conan")
            var mage = new Mage("Gandalf")
            var enemy = new Character("Orc Brute", 100, 20, 5)
            
            "Characters created:".println()
            warrior.getStats().println()
            mage.getStats().println()
            enemy.getStats().println()
            "".println()
            
            // Demonstration combat
            "Mage casts spells:".println()
            mage.castFireball(enemy)
            mage.castHeal()
            "".println()
            
            "Warrior attacks:".println()
            warrior.attackTarget(enemy)
            warrior.attackTarget(enemy)
            warrior.attackTarget(enemy)  // Should trigger rage
            "".println()
            
            // Full battle
            var warrior2 = new Warrior("Aragorn")
            var mage2 = new Mage("Merlin")
            
            Combat.battle(warrior2, mage2)
        }
    }
}
```

## Best Practices Demonstrated

### 1. Proper Encapsulation
- Private fields with public accessors
- Validation in setter methods
- Protected access for inheritance

### 2. Error Handling
- Null return values for error conditions
- Validation of input parameters
- Meaningful error messages

### 3. Resource Management
- Proper initialization in class setup
- State management (active/inactive accounts)
- Resource cleanup when appropriate

### 4. Threading Safety
- Minimal shared state
- Clear thread responsibilities
- Proper thread lifecycle management

### 5. Object-Oriented Design
- Single responsibility principle
- Interface segregation
- Inheritance for is-a relationships
- Composition for has-a relationships

## Next Steps

After studying these examples:

1. **Try modifying them**: Change parameters, add features, or fix edge cases
2. **Combine concepts**: Create programs that use multiple concepts together
3. **Build larger projects**: Use these patterns in more complex applications
4. **Learn advanced topics**: Explore [Native Integration](./12-native-integration.md) and [Threading](./11-threading.md)
5. **Read more documentation**: Check [Project Structure](./15-project-structure.md) and [Compiler Usage](./16-compiler-usage.md)

Happy coding with Am Lang! 🚀