# AmLang Compiler

> **Fast, modern object-oriented programming language that compiles to C**  
> Perfect for cross-platform development, embedded systems, and high-performance applications

[![GitHub Release](https://img.shields.io/github/v/release/anderskjeldsen/am-lang-compiler)](https://github.com/anderskjeldsen/am-lang-compiler/releases)
[![Platform Support](https://img.shields.io/badge/platform-Linux%20%7C%20macOS%20%7C%20Windows-blue)](#installation)
[![Performance](https://img.shields.io/badge/startup-~50ms-green)](#performance)

## 🚀 Why Choose AmLang?

**AmLang** is designed for developers who want the **productivity of modern languages** with the **performance and portability of C**. Whether you're building embedded applications, cross-platform tools, or high-performance systems, AmLang gives you:

### 🎯 **Modern Language Features**
- **Object-oriented programming** with classes, inheritance, and interfaces
- **Built-in unit testing** with comprehensive mocking framework
- **Memory management** with automatic reference counting
- **Concurrency support** with built-in threading
- **Clean syntax** inspired by Kotlin and C#

### 🌍 **Universal Compatibility**
- **Compile anywhere, run everywhere** - generates portable C code
- **Cross-platform builds** for Linux, macOS, AmigaOS, Morphos and more.
- **Native C interop** for seamless library integration


## 📦 Quick Installation

### One-Line Install (Recommended)
```bash
# Auto-detects best version for your system
curl -fsSL https://raw.githubusercontent.com/anderskjeldsen/am-lang-compiler/master/scripts/install-amlc.sh | bash
```

### Platform-Specific Downloads
Download the latest native binary from [GitHub Releases](https://github.com/anderskjeldsen/am-lang-compiler/releases):

- **Linux x64**: `amlc-linux-[version].tar.gz`
- **macOS x64**: `amlc-mac-[version].tar.gz` 
- **macOS ARM64**: `amlc-mac-arm64-[version].tar.gz`
- **Windows x64**: `amlc-windows-[version].zip`
- **Universal JAR**: `amlc-[version].jar` (requires Java 21+)

### Manual Installation
```bash
# Download and extract (example for Linux)
wget https://github.com/anderskjeldsen/am-lang-compiler/releases/latest/download/amlc-linux-0.7.0.tar.gz
tar -xzf amlc-linux-0.7.0.tar.gz
chmod +x amlc-linux

# Verify installation
./amlc-linux --version
```

## 🏃‍♂️ Getting Started

### 1. Write Your First Program
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

### 2. Create Project Structure
```bash
mkdir my-project && cd my-project
amlc new                    # Creates package.yml and src/ directory
```

### 3. Compile and Run
```bash
amlc build                   # Compiles to C and builds executable
amlc run                     # Builds and runs your program
```

## 🎯 Real-World Examples

### Cross-Platform Graphics with Feature Toggles (v0.7.0)
```amlang
namespace Graphics {
    #require opengl
    class Renderer {
        fun initialize() {
            OpenGL.initContext()
        }
    }
    
    #require directx
    class Renderer {
        fun initialize() {
            DirectX.createDevice()
        }
    }
}

// package.yml configures which features to use
// dependencies:
//   - id: graphics-lib
//     features: [opengl]  # Use OpenGL on Linux/macOS
```

### Scientific Computing with Float/Double (v0.7.0)
```amlang
namespace Physics {
    class Particle {
        private var mass: Double = 9.109e-31     // Electron mass (kg)
        private var charge: Double = -1.602e-19  // Elementary charge (C)
        
        fun kineticEnergy(velocity: Float): Double {
            var v = velocity.toDouble()
            return 0.5 * mass * v * v
        }
    }
}
```

### Cross-Platform GUI Application
```amlang
namespace MyApp {
    import Am.Lang
    import Am.Ui
    
    class MainWindow {
        static fun main() {
            var w = Window.openWindow(20S, 20S, 300US, 200US, null, null)
            
            var panel = new Panel()
            panel.setDefaultBorder()
            panel.setDefaultPadding()
            panel.setMargin(w.getScaledX(2S), w.getScaledY(2S))

            var vStack = new VStack(w.getScaledY(2S))
            panel.setChild(vStack)

            var button = new Button("Click Me!", (v) => {
                "Button clicked!".println()
                return true
            })

            button.setup((v) => {
                v.setDefaultPadding()
                v.growX = 255UB
                v.growY = 0UB
            })

            vStack.addChild(button)
            w.setRootView(panel)

            w.layout()
            w.requestRepaint()

            while(w.isOpen()) {
                w.handleInput()
            }
        }
    }
}
```

### Unit Testing with Mocks
```amlang
// tests/DatabaseTest.aml
namespace MyApp.Tests {
    class DatabaseTest {
        test testUserRepository() {
            mock Database {
                fun findUser(id: Int): User {
                    return new User(id, "Test User")
                }
            }
            
            var repo = new UserRepository()
            var user = repo.getUser(123)
            
            if (user.name != "Test User") {
                throw new Exception("Mock failed!")
            }
        }
    }
}
```

## 🛠️ Build System

### Project Configuration (`package.yml`)
```yaml
id: my-awesome-app
version: 1.0
type: application
dependencies:
  - id: am-lang-core
    realm: github
    type: git-repo
    tag: latest
    url: https://github.com/anderskjeldsen/am-lang-core.git
  - id: am-ui
    realm: github
    type: git-repo
    tag: latest
    url: https://github.com/anderskjeldsen/am-ui.git
platforms:
  - id: libc
    abstract: true
  - id: linux-x64
    extends: libc
    gccCommand: gcc
  - id: amigaos
    extends: libc
    gccCommand: m68k-amigaos-gcc
buildTargets:
  - id: linux-x64
    platform: linux-x64
  - id: amigaos
    platform: amigaos
```

### Common Commands
```bash
amlc new                    # Initialize new project
amlc build                   # Build project 
amlc run                     # Build and run
amlc test                    # Run unit tests
amlc lint                    # Check code style (v0.7.0)
amlc docs                    # Generate API documentation (v0.7.0)
amlc clean                   # Clean build artifacts
amlc                       # Show help when no valid command given
```

## 🧪 Testing Framework

AmLang includes a **comprehensive built-in testing framework**:

### Basic Testing
```amlang
class CalculatorTest {
    test testAddition() {
        var calc = new Calculator()
        var result = calc.add(5, 3)
        
        if (result != 8) {
            throw new Exception("Addition failed!")
        }
    }
}
```

### Advanced Mocking
```amlang
class ServiceTest {
    test testWithComplexMock() {
        mock Database {
            fun query(sql: String): ResultSet {
                // Mock implementation
                return mockResultSet()
            }
        }
        
        scope {
            mock Logger {
                fun log(message: String) {
                    // Override logging in this scope
                }
            }
            
            // Test code with both mocks active
        }
        // Logger mock automatically restored here
    }
}
```

## ⚡ Performance

Performance benchmark summary from `examples/performance_test/ReadMe.md`.

Workload used for all runs:
- Iterations: `1000`
- Count per iteration: `100000`
- Modulo: `7` (skip when `i % modulo == 0`)
- Total points processed: `100000000`

| Language | `handlePoints` (array) | `handlePoints2` (no array) |
|---|---:|---:|
| Rust (`rustc -C opt-level=2`) | 476 ms | 331 ms |
| C (pure, gcc -O3) | 986 ms | 846 ms |
| AmLang | 986 ms | 819 ms |
| Go | 1290 ms | 867 ms |
| Java | 1632 ms | 881 ms |
| C# (`struct Point`) | 1946 ms | 826 ms |
| Python | 52151 ms | 34041 ms |

Notes:
- `handlePoints`: create all points in an array, then sum in a second pass.
- `handlePoints2`: create point and sum immediately (no array).
- The modulo branch (`i % modulo == 0`) is intentional: it helps prevent trivial constant-folding/dead-code style optimizations so compilers still emit realistic machine code for the loop workload.
- Full benchmark details: `examples/performance_test/ReadMe.md`.

## 📊 Platform Support

### Native Compilation Targets
- ✅ **Linux x64** - Full support with native binaries
- ✅ **macOS x64** - Intel Mac support
- ✅ **macOS ARM64** - Apple Silicon (M1/M2) support
- ✅ **Windows x64** - Native Windows executables
- ✅ **Amiga** - Classic Amiga cross-compilation
- ✅ **MorphOS** - Modern Amiga-compatible systems

### Runtime Requirements
- **Native binaries**: No runtime dependencies
- **JAR version**: Java 21+ required

## 🐳 Docker Setup for AmigaOS Cross-Compilation

For AmigaOS development, AmLang provides a complete Docker-based cross-compilation environment with the Amiga GCC toolchain and AmiSSL support:

### Quick Setup
```bash
# From the project root
cd docker/amiga-gcc
./build.sh

# Or alternatively, build directly from project root:
docker build -f docker/amiga-gcc/Dockerfile -t amiga-gcc .
```

### Using the Docker Environment
```bash
# Interactive development environment
docker run -it amiga-gcc

# Mount your project for cross-compilation
docker run -it -v $(pwd):/workspace amiga-gcc

# Compile AmLang project for AmigaOS
amlc build . -bt amigaos_docker
```

## 🆕 What's New in v0.9.0

### 🧱 Struct Support Improvements
- Struct declarations and initialization have been improved.
- Nested structs are better supported in everyday usage.
- Better struct-related diagnostics and validation behavior.

### 📌 Struct Semantics
- Struct variables are handled as struct pointers at runtime.
- Passing a struct to a function passes the pointer (shared struct data).
- Returning a struct creates a copy.
- Storing a struct in an array creates a copy of the struct value.
- Reading a struct from an array currently depends on usage.
- Direct element member access (for example `arr[i].x`) works on the array element reference.
- Assigning an element to a struct variable (for example `var p = arr[i]`) creates a copy.
- Planned for v0.10.0: make copy-vs-reference explicit for struct reads (for example use `*arr[i]` for copy), and report compile errors when a reference/value mismatch is ambiguous.

### 🏷️ Struct Initializer Named Fields and Type Stability
- Struct initializer named fields are more reliable and better validated.
- Type-handling improvements reduce edge-case compile failures.
- Better behavior in complex call/type scenarios.

### 🔧 Correctness and Tooling Improvements
- Fixes across overload resolution, expression ordering, static call correctness, and array modification behavior.
- Improved primitive-vs-`null` handling and `return`-statement edge cases.
- Improved release workflow and publish diagnostics.

## 🆕 What's New in v0.8.0

### 🔁 Enhanced `each` Loop Syntax
- Added intuitive iteration syntax: `each(item in collection) { ... }`.
- Existing syntax `each(collection, item)` remains fully supported.

### 🎯 Function Pointer Property Improvements
- Improved direct invocation of function-pointer properties (for example: `this.callback()`).
- Improved C code generation reliability and diagnostics for function-pointer usage.
- Improved memory handling and type validation for callback-style patterns.

### λ Anonymous Function Property Invocation
- Improved direct invocation of anonymous functions stored in properties.
- Improved behavior for patterns like `this.operation(a, b)`.

## 🆕 What's New in v0.7.0

- Feature toggles with `#require` directives for cross-platform development.
- Float/Double support with scientific notation (for example `1.23e-4F`).
- Built-in linting via `amlc lint`.
- API documentation generation via `amlc docs`.

## 🆕 What's New in v0.6.4

### 🧪 **Complete Mocking Framework**
- `mock` keyword for overriding class behavior in tests
- `scope` management for nested mocks with automatic cleanup
- Full integration with existing unit testing framework

## 📚 Learn More

### Examples
Explore real-world projects in the [`examples/`](examples/) directory:
- **Hello World** - Basic program structure
- **File Browser** - GUI application with native file access
- **Image Browser** - Graphics and image processing
- **Unit Testing** - Comprehensive testing examples with mocks

### Official Frameworks
- **[am-json](https://github.com/anderskjeldsen/am-json)** - Comprehensive JSON parsing and serialization library
- **[am-net](https://github.com/anderskjeldsen/am-net)** - Networking utilities and protocols
- **[am-ssl](https://github.com/anderskjeldsen/am-ssl)** - SSL/TLS security library
- **[am-fipm](https://github.com/anderskjeldsen/am-fipm)** - Fixed-point mathematics library
- **[am-ui](https://github.com/anderskjeldsen/am-ui)** - GUI framework for AmLang
- **[am-imaging](https://github.com/anderskjeldsen/am-imaging)** - Image processing library
- **[am-png](https://github.com/anderskjeldsen/am-png)** - PNG format support
