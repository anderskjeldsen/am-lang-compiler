# Getting Started with AmLang

Welcome to **AmLang**! This guide will have you writing and running AmLang programs in minutes.

## 🚀 Quick Start (Recommended)

### One-Line Installation
```bash
# Auto-detects and installs the best version for your system
curl -fsSL https://raw.githubusercontent.com/anderskjeldsen/am-lang-compiler/master/scripts/install-amlc.sh | bash
```

### Verify Installation
```bash
amlc --version
# Output: AmLang Compiler v0.6.4 (native)
```

### Write Your First Program
Create `hello.aml`:
```amlang
namespace HelloWorld {
    class Program {
        fun main() {
            "Hello, AmLang!".println()
        }
    }
}
```

### Compile and Run
```bash
amlc compile hello.aml      # Compiles to C and builds executable
./hello                     # Runs your program
# Output: Hello, AmLang!
```

**🎉 Congratulations!** You've just written, compiled, and run your first AmLang program with zero setup time.

---

## 📦 Installation Options

Choose the installation method that works best for your environment:

### Option 1: Native Binaries (Recommended)
Download platform-specific native executables with **zero dependencies**:

#### Automatic Installation
```bash
# One-line install with auto-detection
curl -fsSL https://raw.githubusercontent.com/anderskjeldsen/am-lang-compiler/master/scripts/install-amlc.sh | bash

# Force native binary installation
curl -fsSL https://raw.githubusercontent.com/anderskjeldsen/am-lang-compiler/master/scripts/install-amlc.sh | bash -s -- --type native
```

#### Manual Download
Visit [GitHub Releases](https://github.com/anderskjeldsen/am-lang-compiler/releases) and download:

- **Linux x64**: `amlc-linux-[version].tar.gz`
- **macOS Intel**: `amlc-mac-[version].tar.gz` 
- **macOS Apple Silicon**: `amlc-mac-arm64-[version].tar.gz`
- **Windows**: `amlc-windows-[version].zip`

```bash
# Example: Linux installation
wget https://github.com/anderskjeldsen/am-lang-compiler/releases/latest/download/amlc-linux-0.6.4.tar.gz
tar -xzf amlc-linux-0.6.4.tar.gz
chmod +x amlc-linux
sudo mv amlc-linux /usr/local/bin/amlc
```

### Option 2: Universal JAR
For maximum compatibility across all platforms (requires Java 21+):

```bash
# Download JAR version
curl -fsSL https://raw.githubusercontent.com/anderskjeldsen/am-lang-compiler/master/scripts/install-amlc.sh | bash -s -- --type jar

# Or download manually
wget https://github.com/anderskjeldsen/am-lang-compiler/releases/latest/download/amlc-0.6.4.jar
java -jar amlc-0.6.4.jar --version
```

---

## 🏃‍♂️ Your First Project

### 1. Create a New Project
```bash
mkdir my-first-project && cd my-first-project
amlc init
```

This creates:
```
my-first-project/
├── package.yml          # Project configuration
├── src/                 # Source code directory
│   └── Main.aml        # Main program file
└── tests/              # Unit tests directory
```

### 2. Edit Your Program
Open `src/Main.aml`:
```amlang
namespace MyFirstProject {
    class Main {
        fun main() {
            "Welcome to my first AmLang project!".println()
            
            var calculator = new Calculator()
            var result = calculator.add(10, 20)
            
            "10 + 20 = ${result}".println()
        }
    }
    
    class Calculator {
        fun add(a: Int, b: Int): Int {
            return a + b
        }
    }
}
```

### 3. Build and Run
```bash
amlc build . -bt linux-x64  # Compiles project in current folder for linux-x64 target (requires package.yml and .aml files under src/)
amlc run . -bt linux-x64    # Builds and runs for linux-x64 target
```

Output:
```
Welcome to my first AmLang project!
10 + 20 = 30
```

---

## 🧪 Adding Unit Tests

### 1. Create a Test File
Create `tests/CalculatorTest.aml`:
```amlang
namespace MyFirstProject.Tests {
    class CalculatorTest {
        import MyFirstProject
        
        test testAddition() {
            var calc = new Calculator()
            var result = calc.add(5, 3)
            
            if (result != 8) {
                throw new Exception("Expected 8, but got ${result}")
            }
        }
        
        test testWithMocking() {
            mock Calculator {
                fun add(a: Int, b: Int): Int {
                    return 100  // Always return 100 for testing
                }
            }
            
            var calc = new Calculator()
            var result = calc.add(1, 1)
            
            if (result != 100) {
                throw new Exception("Expected 100 from mocked add, but got ${result}")
            }
            
            "Mock test passed - returned 100 as expected!".println()
        }
    }
}
```

### 2. Run Tests
```bash
amlc test . -bt linux-x64                    # Runs all tests for linux-x64 target
amlc test . -bt linux-x64 -tests CalculatorTest # Runs specific test class
amlc test . -bt linux-x64 -tests "CalculatorTest testAddition" # Runs specific test method
```

Output:
```
=== AmLang Test Runner ===

=== Running all tests ===

[STARTING] CalculatorTest.testAddition
[PASSED] CalculatorTest.testAddition

[STARTING] CalculatorTest.testWithMocking  
Mock test passed - returned 100 as expected!
[PASSED] CalculatorTest.testWithMocking

=== All tests completed ===

=== Test execution completed ===
```

---

## 🛠️ Project Configuration

### package.yml Structure
```yaml
name: my-awesome-app
version: 1.0.0
description: An awesome AmLang application

dependencies:
  - name: am-lang-core
    version: latest
  - name: am-ui
    version: 1.2.0

testDependencies:
  - name: test-utils
    version: latest

build:
  outputName: my-app
  optimizations: true
  
targets:
  - linux
  - windows
  - amiga
```

### Common Build Commands
```bash
# Project lifecycle
amlc init                      # Create new project
amlc build . -bt linux-x64     # Build project in current folder for linux-x64 target (requires package.yml and .aml files under src/)
amlc run . -bt linux-x64       # Build and run for linux-x64 target
amlc clean . -bt linux-x64     # Clean build artifacts for linux-x64 target

# Development
amlc test . -bt linux-x64      # Run all tests for linux-x64 target
amlc test . -bt linux-x64 -tests "ClassName" # Run specific test class
amlc check               # Check syntax without building

# Advanced
amlc build . -bt linux-x64 --release  # Release build with optimizations for linux-x64
amlc package                           # Create distribution package
```

---

## 🌍 Cross-Platform Development

### Building for Different Platforms
```bash
# Build for your current platform (linux-x64)
amlc build . -bt linux-x64

# Build for specific platforms using build targets
amlc build . -bt linux-x64
amlc build . -bt macos
amlc build . -bt amiga

# Note: Available build targets depend on your package.yml configuration
```

### Platform-Specific Code
```amlang
namespace CrossPlatform {
    class FileManager {
        fun getHomeDirectory(): String {
            // Conditional compilation based on target platform
            #ifdef WINDOWS
                return "C:\\Users\\${getUsername()}"
            #elif LINUX
                return "/home/${getUsername()}"
            #elif MACOS
                return "/Users/${getUsername()}"
            #elif AMIGA
                return "RAM:${getUsername()}"
            #endif
        }
    }
}
```

---

## 🎯 Real-World Examples

### GUI Application
```amlang
namespace MyGUIApp {
    import Am.UI
    
    class MainWindow : Window {
        constructor() {
            this.title = "My AmLang App"
            this.size = new Size(800, 600)
            this.initComponents()
        }
        
        fun initComponents() {
            var button = new Button("Click Me!")
            button.onClick { 
                MessageBox.show("Hello from AmLang!")
            }
            
            var label = new Label("Welcome to AmLang!")
            
            this.layout = new VBoxLayout()
            this.add(label)
            this.add(button)
        }
    }
    
    class App {
        fun main() {
            var window = new MainWindow()
            window.show()
            App.run()  // Start GUI event loop
        }
    }
}
```

### HTTP Server
```amlang
namespace WebServer {
    import Am.Net
    
    class SimpleServer {
        var server: HttpServer
        
        constructor(port: Int) {
            this.server = new HttpServer(port)
            this.setupRoutes()
        }
        
        fun setupRoutes() {
            server.get("/", { request ->
                return "Hello from AmLang HTTP Server!"
            })
            
            server.get("/api/time", { request ->
                return "Current time: ${Date.now()}"
            })
        }
        
        fun start() {
            "Starting server on port ${server.port}...".println()
            server.listen()
        }
    }
    
    class App {
        fun main() {
            var server = new SimpleServer(8080)
            server.start()
        }
    }
}
```

---

## 💡 Tips for New Developers

### 1. **Use Native Binaries for Best Performance**
- Native executables start ~60x faster than JAR versions
- Perfect for CLI tools and frequently-run programs
- Zero runtime dependencies make distribution simple

### 2. **Leverage the Testing Framework**
- Write tests using the `test` keyword in `.aml` files under the `tests/` directory
- Use `throw new Exception()` for test assertions
- Use the `mock` keyword to create mocked implementations for testing
- Run tests with `amlc test . -bt linux-x64` and use `-tests` flag to run specific tests

### 3. **Take Advantage of C Interop**
- AmLang compiles to C, making it easy to integrate existing C libraries
- Use `#include` to include C headers
- Write performance-critical code in inline C when needed

### 4. **Explore the Examples**
- Check out the [`examples/`](../examples/) directory for real-world projects
- Start with `hello-world` and progress to more complex applications
- Each example includes comprehensive comments and best practices

---

## 🆘 Troubleshooting

### Common Issues

#### "Command not found: amlc"
```bash
# Check if amlc is in your PATH
echo $PATH
which amlc

# Re-run installation
curl -fsSL https://raw.githubusercontent.com/anderskjeldsen/am-lang-compiler/master/scripts/install-amlc.sh | bash
```

#### Native Binary Won't Run
```bash
# Check file permissions
chmod +x amlc-linux

# Check if you need the JAR version
curl -fsSL https://raw.githubusercontent.com/anderskjeldsen/am-lang-compiler/master/scripts/install-amlc.sh | bash -s -- --type jar
```

#### Compilation Errors
```bash
# Check syntax
amlc check src/

# Verbose output for debugging
amlc build . -bt linux-x64 --verbose

# Clean and rebuild
amlc clean . -bt linux-x64 && amlc build . -bt linux-x64
```

### Getting Help
- **Documentation**: Explore other guides in the [`docs/`](.) directory
- **Examples**: Real-world code in [`examples/`](../examples/)
- **Issues**: Report bugs or ask questions on [GitHub Issues](https://github.com/anderskjeldsen/am-lang-compiler/issues)

---

## 🎉 What's Next?

Now that you have AmLang up and running:

1. **Explore the Language**: Read the [Language Overview](01-language-overview.md)
2. **Learn the Syntax**: Check out [Syntax & Grammar](02-syntax-grammar.md)
3. **Build Something Cool**: Try the [Examples](19-examples.md)
4. **Join the Community**: Share your projects and get help

**Happy coding with AmLang!** 🚀
