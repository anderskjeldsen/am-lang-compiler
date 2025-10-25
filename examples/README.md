# AmLang Examples

This directory contains comprehensive examples demonstrating AmLang's features and capabilities. Each example is a complete, runnable project that showcases different aspects of the language.

## 🚀 Getting Started

Choose an example based on what you want to learn:

### For Beginners
- **[hello-world](hello-world/)** - Your first AmLang program
- **[loop-keyword-demo](loop-keyword-demo/)** - Basic control flow with `loop` keyword

### For Application Developers  
- **[file-browser](file-browser/)** - GUI application with file system access
- **[image-browser](image-browser/)** - Graphics and image processing

### For Testing & Quality Assurance
- **[unit-testing](unit-testing/)** - Comprehensive testing framework with mocking

## 📚 Example Descriptions

### 🌟 **hello-world**
Perfect starting point for new AmLang developers.
- Basic program structure and syntax
- Simple output and basic operations
- Project setup with `package.yml`

### 🔄 **loop-keyword-demo** 
Demonstrates AmLang's loop control structures.
- `loop` keyword for infinite loops
- `break` statements for loop control
- Counter-based loop patterns

### 📁 **file-browser**
Cross-platform GUI application for browsing files.
- GUI framework integration
- File system operations
- Event handling and user interaction
- Native platform integration

### 🖼️ **image-browser**
Graphics application showcasing image processing.
- Image loading and display
- Graphics operations and transformations
- Memory management for large files
- Cross-platform graphics support

### 🧪 **unit-testing** ⭐ **FEATURED**
**Comprehensive testing framework** showcasing v0.6.4's major features:

#### **Basic Testing**
- `test` keyword for defining test functions
- Professional test execution with `[STARTING]`/`[PASSED]`/`[FAILED]` output
- Test class organization and structure

#### **Mocking Framework** 🎯
- **`mock` keyword** for overriding class behavior
- **Nested mocking** with automatic cleanup
- **Scope management** using `scope { }` blocks
- **Sequential mocking** with proper state isolation

#### **Advanced Testing Patterns**
- **Mock performance testing** - validating mock overhead
- **Edge case testing** - handling error conditions
- **Complex scenarios** - multi-class mocking with dependencies

**Key Test Files:**
- `CalculatorTest.aml` - Basic testing patterns
- `CalculatorMockTest.aml` - Introduction to mocking
- `NestedMocksTest.aml` - Advanced nested mock scenarios
- `MockPerformanceTest.aml` - Performance validation
- `ComplexMockScenariosTest.aml` - Real-world testing patterns

## 🏃‍♂️ Running Examples

### Prerequisites
Make sure AmLang is installed:
```bash
# One-line installation
curl -fsSL https://raw.githubusercontent.com/anderskjeldsen/am-lang-compiler/master/scripts/install-amlc.sh | bash

# Verify installation
amlc --version
```

### Running an Example
```bash
# Navigate to any example directory
cd examples/hello-world

# Build and run
amlc build
amlc run

# Or build and run in one step
amlc build && ./hello-world
```

### Running Tests (unit-testing example)
```bash
cd examples/unit-testing

# Run all tests
amlc test

# Run specific test class
amlc test CalculatorTest

# Run specific test method
amlc test CalculatorTest.testAddition

# Run mock-related tests
amlc test CalculatorMockTest NestedMocksTest
```

## 🎯 Learning Path

### 1. **Start with Basics**
```bash
cd examples/hello-world
amlc run
```

### 2. **Learn Language Features**
```bash
cd examples/loop-keyword-demo  
amlc run
```

### 3. **Explore Testing (RECOMMENDED)**
```bash
cd examples/unit-testing
amlc test                    # See basic testing
amlc test CalculatorMockTest # Experience mocking
```

### 4. **Build Real Applications**
```bash
cd examples/file-browser     # GUI applications
amlc run
```

## 💡 What You'll Learn

### **Language Fundamentals**
- AmLang syntax and project structure
- Object-oriented programming patterns
- Cross-platform development techniques

### **Modern Development Practices**
- **Unit testing** with professional test output
- **Mocking** for isolated component testing  
- **Test-driven development** workflows

### **Performance & Deployment**
- **Native compilation** for maximum performance
- **Cross-platform builds** for universal compatibility
- **Zero-dependency deployment** strategies

### **Advanced Features**
- **GUI development** with native platform integration
- **File and image processing** for real-world applications
- **Memory management** and resource optimization

## 🚀 Performance Benefits

All examples demonstrate AmLang's **native compilation advantages**:

- **~50ms startup time** - Applications start instantly
- **~50MB memory usage** - Efficient resource utilization  
- **Zero dependencies** - Distribute single executable files
- **Native performance** - C-level execution speed

## 🤝 Contributing Examples

We welcome community examples! When creating new examples:

1. **Include comprehensive README** explaining the example's purpose
2. **Add meaningful comments** to help learners understand the code
3. **Demonstrate best practices** for the features being showcased
4. **Provide multiple complexity levels** from basic to advanced
5. **Include tests** when applicable

## 📖 More Resources

- **[Getting Started Guide](../docs/18-getting-started.md)** - Complete setup and first steps
- **[Language Overview](../docs/01-language-overview.md)** - Core language concepts
- **[Project Documentation](../docs/)** - Comprehensive language reference

---

**Ready to explore?** Start with `examples/hello-world` and work your way up to the comprehensive `examples/unit-testing` to see AmLang's full potential! 🎉
