# Getting Started

This guide will help you get up and running with Am Lang, from installation to writing your first program.

## Prerequisites

Before you begin, make sure you have the following installed:

- **Java 20 or later** - Required for running the Am Lang compiler
- **Maven 3.6 or later** - For building the compiler and managing dependencies
- **GCC** - For compiling the generated C code to native binaries
- **Git** - For cloning the repository
- **Docker** (optional) - For cross-compilation to specific platforms like Amiga

### Checking Prerequisites

```bash
# Check Java version
java -version

# Check Maven version
mvn -version

# Check GCC version
gcc --version

# Check Git version
git --version
```

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/anderskjeldsen/am-lang-compiler-code.git
cd am-lang-compiler-code
```

### 2. Build the Compiler

```bash
# Build the project
mvn clean compile jar:jar shade:shade -DskipTests
```

This creates the Am Lang compiler JAR file in the `target` directory.

### 3. Verify Installation

```bash
# Check if the compiler was built successfully
ls -la target/amlc-*.jar

# Test the compiler (should show help/usage information)
java -jar target/amlc-0.6.0.jar
```

### Alternative: Running Without Shaded JAR

If you encounter signature verification errors with the shaded JAR:

```bash
# Copy dependencies
mvn dependency:copy-dependencies -DoutputDirectory=target/dependency

# Run compiler directly
java -cp "target/classes:target/dependency/*" no.kelson.asharpcompiler.Main [command] [path] [options]
```

## Your First Am Lang Program

### 1. Create a Project Directory

```bash
mkdir my-first-amlang-project
cd my-first-amlang-project
```

### 2. Create a Package Configuration

Create a `package.yml` file:

```yaml
name: "my-first-project"
version: "1.0.0"
description: "My first Am Lang project"

build-targets:
  native:
    type: "native"
    compiler: "gcc"
    flags: ["-O2"]

dependencies: []
```

### 3. Create Source Directory and File

```bash
mkdir src
```

Create `src/main.as` with your first program:

```amlang
namespace HelloWorld {
    class Main {
        static fun main() {
            "Hello, Am Lang World!".println()
            
            var name = "Developer"
            var greeting = "Welcome to Am Lang, ${name}!"
            greeting.println()
            
            // Demonstrate basic arithmetic
            var x = 10
            var y = 20
            var sum = x + y
            "The sum of ${x} and ${y} is ${sum}".println()
        }
    }
}
```

### 4. Build and Run Your Program

```bash
# Navigate back to the compiler directory
cd /path/to/am-lang-compiler-code

# Build your project
java -jar target/amlc-0.6.0.jar build /path/to/my-first-amlang-project -bt native

# Run your project
java -jar target/amlc-0.6.0.jar run /path/to/my-first-amlang-project -bt native
```

Expected output:
```
Hello, Am Lang World!
Welcome to Am Lang, Developer!
The sum of 10 and 20 is 30
```

## Understanding the Code

Let's break down the first program:

### Namespace Declaration
```amlang
namespace HelloWorld {
    // All code goes here
}
```
- Namespaces organize code into logical modules
- Similar to packages in Java or namespaces in C#

### Class Declaration
```amlang
class Main {
    // Class members
}
```
- Classes are the basic building blocks of Am Lang programs
- Every executable program needs a class with a `main` function

### Main Function
```amlang
static fun main() {
    // Program entry point
}
```
- The `main` function is the entry point for program execution
- Must be `static` so it can be called without creating an instance

### String Operations
```amlang
"Hello, Am Lang World!".println()
```
- Strings support method calls directly
- `println()` prints the string followed by a newline

### Variables
```amlang
var name = "Developer"
var x = 10
```
- Use `var` to declare mutable variables
- Type inference automatically determines the type

### String Interpolation
```amlang
var greeting = "Welcome to Am Lang, ${name}!"
```
- Use `${}` syntax to embed expressions in strings
- Similar to template literals in JavaScript or string interpolation in Kotlin

## Project Structure

A typical Am Lang project follows this structure:

```
my-project/
├── package.yml          # Project configuration
├── src/                 # Source files
│   ├── main.as         # Main program file
│   └── utils.as        # Additional source files
├── builds/             # Generated build files (created by compiler)
│   ├── native/         # Native build target output
│   └── c/              # Generated C code
└── dependencies/       # External dependencies (if any)
```

## Common Compiler Commands

### Build Command
```bash
java -jar amlc-0.6.0.jar build <project-path> -bt <build-target>
```

### Run Command
```bash
java -jar amlc-0.6.0.jar run <project-path> -bt <build-target>
```

### Clean Command
```bash
java -jar amlc-0.6.0.jar clean <project-path> -bt <build-target>
```

### Command Options
- `-bt <target>`: Specify build target (default: native)
- `-fld`: Force load dependencies
- `-rl`: Enable runtime logging
- `-cl`: Enable conditional logging
- `-ll <0-5>`: Set log level (0 to 5)
- `-rdc`: Render debug comments
- `-cores=X`: Set number of cores for parallel compilation

## Examples to Try

### 1. Calculator Program

Create `src/calculator.as`:

```amlang
namespace Calculator {
    class SimpleCalculator {
        static fun add(a: Int, b: Int): Int {
            return a + b
        }
        
        static fun multiply(a: Int, b: Int): Int {
            return a * b
        }
        
        static fun divide(a: Int, b: Int): Int {
            if (b != 0) {
                return a / b
            } else {
                "Error: Division by zero".println()
                return 0
            }
        }
    }
    
    class Main {
        static fun main() {
            var x = 15
            var y = 3
            
            var sum = SimpleCalculator.add(x, y)
            var product = SimpleCalculator.multiply(x, y)
            var quotient = SimpleCalculator.divide(x, y)
            
            "Calculator Results:".println()
            "${x} + ${y} = ${sum}".println()
            "${x} * ${y} = ${product}".println()
            "${x} / ${y} = ${quotient}".println()
        }
    }
}
```

### 2. Person Class Example

Create `src/person.as`:

```amlang
namespace PersonExample {
    class Person(var name: String, var age: Int) {
        fun greet(): String {
            return "Hello, I'm ${name} and I'm ${age} years old"
        }
        
        fun haveBirthday() {
            age++
            "Happy birthday! I'm now ${age} years old".println()
        }
        
        fun isAdult(): Bool {
            return age >= 18
        }
    }
    
    class Main {
        static fun main() {
            var person = new Person("Alice", 17)
            
            person.greet().println()
            
            if (person.isAdult()) {
                "Person is an adult".println()
            } else {
                "Person is a minor".println()
            }
            
            person.haveBirthday()
            
            if (person.isAdult()) {
                "Person is now an adult".println()
            }
        }
    }
}
```

### 3. Threading Example

Create `src/threading.as`:

```amlang
namespace ThreadingExample {
    class CounterTask(private var name: String, private var count: Int) : Runnable {
        
        override fun run() {
            for (i in 1 to count) {
                "${name}: ${i}".println()
                Thread.sleep(500)
            }
            "${name} finished".println()
        }
    }
    
    class Main {
        static fun main() {
            "Starting threading example...".println()
            
            var task1 = new CounterTask("Thread-A", 5)
            var task2 = new CounterTask("Thread-B", 3)
            
            var thread1 = new Thread(task1)
            var thread2 = new Thread(task2)
            
            thread1.name = "Counter-A"
            thread2.name = "Counter-B"
            
            thread1.start()
            thread2.start()
            
            thread1.join()
            thread2.join()
            
            "All threads completed".println()
        }
    }
}
```

## Build Targets

Am Lang supports multiple build targets:

### Native Target
Compiles to native code for the current platform:
```bash
java -jar amlc-0.6.0.jar build myproject -bt native
```

### Custom Targets
You can define custom build targets in `package.yml`:
```yaml
build-targets:
  debug:
    type: "native"
    compiler: "gcc"
    flags: ["-g", "-O0"]
  
  release:
    type: "native"
    compiler: "gcc"
    flags: ["-O3", "-DNDEBUG"]
    
  amiga:
    type: "cross"
    compiler: "m68k-amigaos-gcc"
    flags: ["-O2", "-fomit-frame-pointer"]
```

## Troubleshooting

### Common Issues

#### 1. Java Version Issues
```bash
# Error: Unsupported class file major version
# Solution: Make sure you're using Java 20 or later
java -version
```

#### 2. Maven Build Errors
```bash
# Error: Command not found: mvn
# Solution: Install Maven or check PATH
mvn -version
```

#### 3. GCC Not Found
```bash
# Error: gcc: command not found
# Solution: Install GCC
# On Ubuntu/Debian: sudo apt install gcc
# On macOS: xcode-select --install
# On Windows: Install MinGW or use WSL
```

#### 4. Permission Errors
```bash
# Error: Permission denied
# Solution: Make sure you have write permissions
chmod +x target/amlc-0.6.0.jar
```

### Getting Help

- **Documentation**: Check the other documentation files in the `docs/` directory
- **Examples**: Look at the test files in `src/main/resources/` for more examples
- **Issues**: Report bugs on the GitHub repository
- **Build Logs**: Use `-ll 5` for maximum logging when debugging build issues

## Next Steps

Now that you have Am Lang running:

1. **Learn the Language**: Read through the [Language Overview](./01-language-overview.md)
2. **Explore Features**: Check out [Classes and Objects](./06-classes-objects.md)
3. **Advanced Topics**: Learn about [Threading](./11-threading.md) and [Native Integration](./12-native-integration.md)
4. **Build Systems**: Understand [Project Structure](./15-project-structure.md) and [Build Targets](./17-build-targets.md)
5. **More Examples**: Study the [Examples](./19-examples.md) documentation

Welcome to Am Lang development! 🚀