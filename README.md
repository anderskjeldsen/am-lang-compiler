# AmLang Compiler

AmLang is a modern object-oriented programming language designed for systems programming with a focus on cross-platform compatibility. The AmLang compiler (`amlc`) translates AmLang source code into optimized C code, enabling deployment across various platforms including embedded systems and legacy architectures like Amiga.

## Features

- **Object-Oriented Programming**: Classes, inheritance, interfaces, and polymorphism
- **Memory Management**: Automatic reference counting with optional memory leak tracking
- **Concurrency**: Built-in threading support with suspend functions
- **Cross-Platform**: Compile to C for maximum portability
- **Native Interop**: Seamless integration with native C libraries
- **Modern Syntax**: Clean, expressive syntax inspired by Kotlin and C#

### 🆕 New in v0.6.3

**🧪 Complete Unit Testing Framework**: AmLang now includes a comprehensive built-in testing framework with dedicated syntax, tooling, and execution environment:

```amlang
// tests/CalculatorTest.aml - Tests in dedicated tests/ directory
namespace MyProject.Tests {
    class CalculatorTest {
        test testAddition() {  // 'test' keyword - no parameters allowed
            var calculator = new Calculator()
            var result = calculator.add(5, 3)
            if (result == 8) {
                "Addition test passed".println()
            } else {
                "Addition test failed".println()
            }
        }
        
        test testDivisionByZero() {
            var calculator = new Calculator()
            var result = calculator.divide(10, 0)
            // Test edge cases and error handling
        }
    }
}
```

**Key Testing Features**:
- **`test` keyword**: Define test functions (only allowed in `tests/` directory)
- **Separate build system**: Test executables built to `builds/test-bin/` directory  
- **Test selection**: Run all tests, specific classes, or individual methods
- **Professional output**: Clear `[STARTING]`, `[PASSED]`, `[FAILED]` status indicators
- **testOnly dependencies**: Dependencies that only load during test execution
- **Parameter validation**: Test functions cannot accept parameters for consistency
- **Instance handling**: Test methods receive proper class instances

**Test Command Usage**:
```bash
# Run all tests for specific build target
java -jar amlc.jar test . -bt native

# Run specific test class
java -jar amlc.jar test . -bt native -tests CalculatorTest

# Run specific test methods
java -jar amlc.jar test . -bt native -tests "CalculatorTest testAddition"

# Run multiple tests/classes
java -jar amlc.jar test . -bt native -tests "CalculatorTest StringTest"
```

**testOnly Dependencies**: Optimize production builds by excluding test-specific dependencies:
```yaml
# package.yml
dependencies:
  - id: "production-lib"
    type: "git-repo"
    url: "..."
    testOnly: false  # Available in both build and test
    
  - id: "test-framework"
    type: "git-repo"
    url: "..."
    testOnly: true   # Only loaded during test mode
```

### 🆕 New in v0.6.2

- **Switch statements**: C-style switch statements with `switch (expr) { case value: ... default: ... }` syntax

### 🆕 New in v0.6.1

- **🔥 String Interpolation**: `"Hello $name"` and `"Result: ${x + y}"` syntax
- **📚 Array Initializers**: Modern syntax `var arr: String[] = ["Hello", "World"]`
- **⚡ Anonymous Functions**: Lambda expressions with `() => { return value }`
- **🔄 Enhanced Loops**: Range-based `for(i = 0 to 10)` syntax
- **🎯 Advanced Generics**: Complete generic programming support
- **🔗 Native Integration**: Seamless C library integration framework
- **🧵 Threading & Concurrency**: Built-in thread management and suspend functions
- **📋 Command Line Arguments**: Main functions can now accept command line arguments with `main(args: String[])`

## Language Overview

AmLang combines the best features of modern programming languages while maintaining compatibility with low-level system programming:

```amlang
namespace MyApp {
    class Person(var name: String, var age: Int) {
        fun greet(): String {
            // String interpolation syntax (v0.6.1)
            return "Hello, I'm ${name} and I'm ${age} years old"
        }
        
        fun haveBirthday() {
            age++
            // Simple variable interpolation
            "Happy birthday $name!".print()
        }
        
        fun getAgeGroup(): String {
            // New v0.6.3 switch statement with testing support!
            switch (age) {
                case 0:
                    return "Newborn"
                case 1:
                    return "Infant" 
                default:
                    if (age < 13) {
                        return "Child"
                    } else {
                        return "Adult"
                    }
            }
        }
    }
    
    class Main {
        static fun main(args: String[]) {
            var person = new Person("Alice", 25)
            person.greet().print()
            person.haveBirthday()
            
            // Switch statement for command processing (v0.6.3)
            var command = if (args.length > 0) args[0] else "help"
            switch (command) {
                case "greet":
                    person.greet().print()
                case "age":
                    person.getAgeGroup().print()  
                case "help":
                    "Available commands: greet, age, help".print()
                default:
                    "Unknown command: ${command}".print()
            }
            
            // Array initializer syntax (v0.6.1)
            var friends: String[] = ["Bob", "Charlie", "David"]
            for(i = 0 to friends.length) {
                "Friend: ${friends[i]}".print()
            }
        }
    }
}
```

### Key Language Features

- **Namespaces**: Organize code into logical modules
- **Classes and Inheritance**: Full OOP support with single inheritance
- **Control Flow**: Complete set including if/else, loops, and switch-case statements
- **Native Classes**: Direct integration with C libraries
- **Threading**: Built-in `Thread` class and `Runnable` interface
- **Arrays**: Type-safe array syntax with initializer support
- **String Interpolation**: Embedded expressions in strings
- **Suspend Functions**: Coroutine-style asynchronous programming

## Getting Started

### Prerequisites

- **Java 20+**: Required for running the compiler
- **Maven 3.6+**: For building the project
- **GCC**: For compiling generated C code
- **Docker** (optional): For cross-compilation to specific platforms

### Usage

The AmLang compiler supports several commands:

```bash
# Compile a project
java -jar amlc-0.6.3.jar build /path/to/project -bt [build-target]

# Clean build artifacts
java -jar amlc-0.6.3.jar clean /path/to/project -bt [build-target]

# Compile and run
java -jar amlc-0.6.3.jar run /path/to/project -bt [build-target]

# 🆕 Run unit tests
java -jar amlc-0.6.3.jar test /path/to/project -bt [build-target] [test-names...]
```

#### Unit Testing Framework (New in v0.6.3)

AmLang includes a comprehensive built-in unit testing framework with dedicated syntax, separate build system, and professional test execution:

```bash
# Run all tests in the project
java -jar amlc-0.6.3.jar test . -bt native

# Run specific test class
java -jar amlc-0.6.3.jar test . -bt native -tests CalculatorTest

# Run specific test methods
java -jar amlc-0.6.3.jar test . -bt native -tests "CalculatorTest testAddition"

# Run multiple tests/classes
java -jar amlc-0.6.3.jar test . -bt native -tests "CalculatorTest StringTest testSpecific"
```

**Key Features**:
- **`test` keyword**: Define test functions with `test myTest() { ... }` syntax
- **Directory separation**: Tests in `tests/` directory, source in `src/` directory
- **Separate build system**: Test executables built to `builds/test-bin/` directory
- **Professional output**: Clear `[STARTING]`, `[PASSED]`, `[FAILED]` status indicators
- **Test selection**: Run all tests, specific classes, or individual methods
- **testOnly dependencies**: Dependencies that only load during test mode
- **Parameter validation**: Test functions cannot accept parameters for consistency

**Test Structure**: Create test files in a `tests/` directory alongside your `src/` directory:

```
my-project/
├── package.yml
├── src/
│   └── Calculator.aml          # Your source code
├── tests/
│   └── CalculatorTest.aml      # Your test files
└── builds/
    ├── bin/                    # Regular application builds
    └── test-bin/               # Test executable builds
```

**Test File Syntax**:

```amlang
// tests/CalculatorTest.aml
namespace MyProject.Tests {
    class CalculatorTest {
        import Am.Lang
        import MyProject
        
        test testAddition() {       // No parameters allowed
            var calculator = new Calculator()
            var result = calculator.add(5, 3)
            if (result == 8) {
                "Addition test passed".println()
            } else {
                "Addition test failed".println()
            }
        }
        
        test testSubtraction() {
            var calculator = new Calculator()
            var result = calculator.subtract(10, 4)
            if (result == 6) {
                "Subtraction test passed".println()
            }
        }
        
        test testDivisionByZero() {
            var calculator = new Calculator()
            // Test edge cases and error handling
            var result = calculator.divide(10, 0)
            // Handle expected behavior for division by zero
        }
    }
}
```

**testOnly Dependencies**: Optimize production builds by excluding test-specific dependencies:

```yaml
# package.yml
dependencies:
  - id: "production-lib"
    type: "git-repo"
    url: "https://github.com/example/prod-lib.git"
    testOnly: false  # Available in both build and test mode
    
  - id: "test-framework"
    type: "git-repo"
    url: "https://github.com/example/test-framework.git"
    testOnly: true   # Only loaded during test mode
```

**Test Output Example**:
```
=== AmLang Test Runner ===

=== Running all tests ===

[STARTING] CalculatorTest.testAddition
[PASSED] CalculatorTest.testAddition

[STARTING] CalculatorTest.testSubtraction
[PASSED] CalculatorTest.testSubtraction

[STARTING] CalculatorTest.testDivisionByZero
[PASSED] CalculatorTest.testDivisionByZero

=== All tests completed ===
```

```
my-project/
├── package.yml
├── src/
│   └── Calculator.aml      # Your source code
└── tests/
    └── CalculatorTest.aml  # Your test files
```

**Test Syntax**: Use the `test` keyword instead of `fun` for test methods:

```amlang
// tests/CalculatorTest.aml
namespace MyProject.Tests {
    class CalculatorTest {
        import Am.Lang
        import MyProject  // Import your source classes
        
        test testAddition() {
            var result = 5 + 3
            if (result == 8) {
                "Addition test passed".println()
            } else {
                "Addition test failed".println()
            }
        }
        
        test testSubtraction() {
            var result = 10 - 4
            if (result == 6) {
                "Subtraction test passed".println()
            } else {
                "Subtraction test failed".println()
            }
        }
    }
}
```

**Key Features**:
- ✅ The `test` keyword is only allowed in files within the `tests/` directory
- ✅ Test files have full access to classes in `src/` directories
- ✅ Test functions work just like regular functions but are marked for test execution
- ✅ Attempting to use `test` in `src/` files will result in a compiler error

#### Command Line Options

- `-bt [target]`: Specify build target (platform)
- `-fld`: Force load dependencies
- `-rl`: Enable runtime logging
- `-cl`: Enable conditional logging
- `-ll [0-5]`: Set log level (0 to 5)
- `-rdc`: Render debug comments
- `-cores=X`: Set number of cores for parallel compilation (default: 4)

### Project Structure

An AmLang project typically follows this structure:

```
my-project/
├── package.yml          # Project configuration
├── src/
│   └── main.aml        # Source files
├── tests/              # Unit test files (🆕 v0.6.3)
│   └── MainTest.aml    # Test files using 'test' keyword
├── builds/             # Generated build files
└── dependencies/       # External dependencies
```

## Build Targets

AmLang supports multiple build targets for cross-platform compilation:

- **Native**: Native integration for any platform
- **Amiga**: Cross-compile for Amiga systems using Docker
- **Custom**: Define custom build targets with specific toolchains

Build targets are configured in the project's `package.yml` file.

## Support

- **Issues**: Report bugs and feature requests on [GitHub Issues](https://github.com/anderskjeldsen/am-lang-compiler-code/issues)
- **Discussions**: Join the community discussions for questions and support

# Quick start (for AmigaOS3):

Set up your Docker image for Amiga GCC (using the Docker file in docker/amiga-gcc):
```bash
# From the project root
cd docker/amiga-gcc
./build.sh

# Or alternatively, build directly from project root:
docker build -f docker/amiga-gcc/Dockerfile -t amiga-gcc .
```

The Docker image includes the complete Amiga GCC toolchain with AmiSSL support for cross-compilation to AmigaOS.

A simple way to get started is to go to the examples folder and try out the hello-world example.

Then run the compiler:

```bash
java -jar amlc.jar build . -bt amigaos_docker
```

# Code example

The following code fills up a HashSet and times it.

```java
namespace Am.Examples {    

    class CoreStartup {
        import Am.Lang
        import Am.Lang.Diagnostics
        import Am.IO
        import Am.IO.Networking
        import Am.Collections

        static fun main() {
            var set = new HashSet<Int>()
            var startDate = Date.now()
            var max = 1000000
            ("Adding " + max.toString() + " key-value pairs to a HashSet").println()
            for(i = 0 to max) {                
                set.add(i)
            }

            var endDate = Date.now()

            ("Time: " + (endDate.getValue() - startDate.getValue()).toString() + "ms").println()

            var testVal = 4
            var iset = set as Set<Int>
            var hasValue = iset.has(testVal)

            if (hasValue) {
                "found".println()
            } else {
                "not found".println()
            }
        }
    }
}
```

# Official repos

## am-lang-core

Core functionality of the AmLang programming language.

https://github.com/anderskjeldsen/am-lang-core

## am-net

Networking capabilities for AmLang.

https://github.com/anderskjeldsen/am-net

## am-ssl

SSL/TLS support for AmLang.

https://github.com/anderskjeldsen/am-ssl

## am-ui

User interface components for AmLang (Amiga / Morphos)

https://github.com/anderskjeldsen/am-ui

## am-imaging

Imaging capabilities for AmLang.

https://github.com/anderskjeldsen/am-imaging

## am-png

PNG image format support for AmLang.

https://github.com/anderskjeldsen/am-png

# Try AmLang for yourself

CURRENTLY OUTDATED:
We've made a web-based playground (IDE) that you can try here: https://www.kelson.no/tools/amlangide
