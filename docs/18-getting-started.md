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
# Output: AmLang Compiler v0.6.4
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
# For single file compilation, create a simple project first
mkdir hello-project && cd hello-project
amlc new .                  # Creates package.yml and src/ directory
# Move your hello.aml to src/am-lang/HelloWorld/Program.aml
amlc build . -bt linux-x64  # Builds project for Linux x64
amlc run . -bt linux-x64    # Runs the program
# Output: Hello, AmLang!
```

**🎉 Congratulations!** You've just written, compiled, and run your first AmLang program!

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
java -jar amlc-0.6.4.jar new my-project  # Test installation
```

---

## 🏃‍♂️ Your First Project

### 1. Create a New Project
```bash
mkdir my-first-project && cd my-first-project
amlc new .
```

This creates:
```
my-first-project/
├── package.yml          # Project configuration
├── src/                 # Source code directory
│   └── am-lang/        # AmLang source files
└── Makefile            # Build configuration
```

### 2. Edit Your Program
The `amlc new` command will prompt you for:
- **Project name**: e.g., "MyFirstProject"
- **Root namespace**: e.g., "MyFirstProject"

This creates `src/am-lang/MyFirstProject/Program.aml`:
```amlang
namespace MyFirstProject {
    class Program {
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
# Build for your platform (replace linux-x64 with your target)
amlc build . -bt linux-x64

# Run the built program
amlc run . -bt linux-x64
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
                throw new Exception("Addition failed! Expected 8, got ${result}")
            }
            
            "Addition test passed!".println()
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
                throw new Exception("Mock failed!")
            }
            
            "Mock test passed!".println()
        }
    }
}
```

### 2. Run Tests
```bash
# Run all tests
amlc test . -bt linux-x64

# Run specific test class
amlc test . -bt linux-x64 -tests "CalculatorTest"

# Run specific test method
amlc test . -bt linux-x64 -tests "CalculatorTest testAddition"
```

Output:
```
[STARTING] CalculatorTest.testAddition
Addition test passed!
[PASSED] CalculatorTest.testAddition

[STARTING] CalculatorTest.testWithMocking  
Mock test passed!
[PASSED] CalculatorTest.testWithMocking

Tests completed: 2 passed, 0 failed
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

build:
  optimizations: true
  
targets:
  - linux-x64
  - windows-x64
  - amigaos
  - morphos
```

### Available Commands
```bash
# Project lifecycle
amlc new [path]                    # Create new project
amlc build [path] -bt [target]     # Build project for target platform
amlc run [path] -bt [target]       # Build and run project
amlc clean [path] -bt [target]     # Clean build artifacts

# Testing
amlc test [path] -bt [target]                     # Run all tests
amlc test [path] -bt [target] -tests "ClassName"  # Run specific test class
amlc test [path] -bt [target] -tests "ClassName testMethod"  # Run specific test

# Options
-bt [target]          # Build target (e.g., linux-x64, windows-x64, macos-x64)
-cores [n]            # Number of CPU cores for compilation (default: 4)
-fld                  # Force load dependencies
-tests "[names]"      # Specify test classes/methods to run
```

### Common Build Targets
```bash
# Platform targets
-bt linux-x64         # Linux 64-bit
-bt windows-x64       # Windows 64-bit  
-bt macos-x64         # macOS Intel 64-bit
-bt macos-arm64       # macOS Apple Silicon
-bt amigaos           # AmigaOS
-bt morphos           # MorphOS
```

---

## 🌍 Cross-Platform Development

### Building for Different Platforms
```bash
# Build for current platform
amlc build . -bt linux-x64

# Build for Windows (from Linux/macOS with cross-compilation)
amlc build . -bt windows-x64

# Build for macOS
amlc build . -bt macos-x64

# Build for AmigaOS
amlc build . -bt amigaos

# Build for MorphOS
amlc build . -bt morphos
```


---


---

## 💡 Tips for New Developers

### 1. **Use Native Binaries for Best Performance**
- Native executables start ~60x faster than JAR versions
- Perfect for CLI tools and frequently-run programs
- Zero runtime dependencies make distribution simple

### 2. **Leverage the Testing Framework**
- Write tests early and often using the `test` keyword
- Use mocking to isolate components and test edge cases
- Run tests frequently during development

### 3. **Explore the Examples**
- Check out the [`examples/`](../examples/) directory for real-world projects
- Start with `hello-world` and progress to more complex applications
- Each example includes comprehensive comments and best practices

---

