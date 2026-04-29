# AmLang Compiler v0.6.3 - Feature Overview

**Release Date:** October 3, 2025  
**Major Release:** Complete Unit Testing Framework Implementation

## 🎉 Major New Features

### 1. **Unit Testing Framework** 🧪
Complete built-in unit testing framework with dedicated syntax, tooling, and execution environment:

- **`test` keyword:** Define test functions with `test myTest() { ... }` syntax
- **Directory separation:** Tests in `tests/` directory, source in `src/` directory
- **Separate build system:** Test executables built to `builds/test-bin/` directory
- **Test selection:** Run all tests, specific classes, or individual test methods
- **Professional output:** Clear `[STARTING]`, `[PASSED]`, `[FAILED]` status indicators
- **testOnly dependencies:** Dependencies that only load during test mode
- **Parameter validation:** Test functions cannot accept parameters for consistency
- **Instance handling:** Test methods receive proper class instances

**Basic Test Example:**
```amlang
// tests/CalculatorTest.aml
namespace MyProject.Tests {
    class CalculatorTest {
        import Am.Lang
        import MyProject
        
        test testAddition() {
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
            var result = calculator.divide(10, 0)
            // Test edge cases and error handling
        }
    }
}
```

**Test Command Usage:**
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

**testOnly Dependencies:**
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

## 🔧 Technical Improvements

### Compiler Architecture
- **Test keyword parsing:** New `test` keyword exclusively for test methods in `tests/` directory
- **Build mode separation:** Distinct compilation paths for production (`build`) and testing (`test`)
- **Test executable generation:** Separate output directory (`builds/test-bin/`) for test binaries
- **Parameter validation:** Compiler enforces that test methods cannot accept parameters

### Language Processing  
- **Keywords added:** `test` keyword integrated into language grammar
- **Directory validation:** `test` keyword only allowed in files within `tests/` directory
- **Test method detection:** Parser identifies and validates test methods during compilation
- **Instance management:** Test methods receive proper class instances for execution

### Build System Enhancements
- **Test command:** New `test` command alongside existing `build`, `run`, and `clean`
- **Test selection:** Command-line options to run specific test classes or methods
- **Dependency filtering:** testOnly dependencies excluded from production builds
- **Output organization:** Separate directories for production and test artifacts

### Developer Experience
- **Professional output:** Clear test status indicators (`[STARTING]`, `[PASSED]`, `[FAILED]`)
- **Flexible execution:** Run all tests, specific classes, or individual methods
- **Error validation:** Compiler catches invalid test method signatures
- **Clean separation:** Tests isolated from production code in dedicated directory

## 🧪 Quality Assurance

### Test Coverage
- **Compiler tests:** Validation of test keyword parsing and binding
- **Build system tests:** Verification of test command functionality
- **Integration tests:** End-to-end testing of complete test workflow
- **Example programs:** Working test examples in documentation

### Validation Testing
- **Directory validation:** Tests ensuring `test` keyword restricted to `tests/` directory
- **Parameter validation:** Tests confirming test methods cannot accept parameters
- **Build separation:** Tests verifying correct output directory usage
- **Dependency filtering:** Tests for testOnly dependency handling

### Example Programs
- **Calculator tests:** Complete example in `examples/unit-testing/`
- **Basic tests:** Simple test method demonstrations
- **Integration examples:** Real-world test scenarios
- **Error cases:** Examples of validation errors

## 📦 Installation & Usage  

### Updated CLI Commands
```bash
# Compile a project
java -jar amlc-0.6.3.jar build /path/to/project -bt [target]

# Run unit tests (NEW in v0.6.3)
java -jar amlc-0.6.3.jar test /path/to/project -bt [target] [-tests "class method..."]

# Run and test workflow
java -jar amlc-0.6.3.jar run /path/to/project -bt [target]

# All existing options remain unchanged
-cores=X      # Parallel compilation  
-rl           # Runtime logging
-cl           # Conditional logging
-ll [0-5]     # Log level control
-rdc          # Debug comments in output
-fld          # Force load dependencies
```

### Test Directory Structure
```
my-project/
├── package.yml          # Project configuration
├── src/
│   └── Calculator.aml   # Source code
├── tests/               # NEW: Test directory
│   └── CalculatorTest.aml  # Test files using 'test' keyword
├── builds/
│   ├── bin/            # Production builds
│   └── test-bin/       # Test builds (NEW)
└── dependencies/       # External dependencies
```

### Test Method Syntax
```amlang
namespace MyProject.Tests {
    class MyTest {
        // Test method - no parameters allowed
        test myTestMethod() {
            // Test logic here
            var result = someFunction()
            if (result == expected) {
                "Test passed".println()
            } else {
                "Test failed".println()
            }
        }
        
        // Multiple test methods in same class
        test anotherTestMethod() {
            // Another test
        }
    }
}
```

### Integration Examples
```amlang
// tests/StringUtilsTest.aml
namespace MyApp.Tests {
    class StringUtilsTest {
        import Am.Lang
        import MyApp.Utils
        
        test testTrimFunction() {
            var utils = new StringUtils()
            var result = utils.trim("  hello  ")
            if (result == "hello") {
                "Trim test passed".println()
            }
        }
        
        test testUpperCase() {
            var utils = new StringUtils()
            var result = utils.toUpperCase("hello")
            if (result == "HELLO") {
                "UpperCase test passed".println()
            }
        }
    }
}
```

## 🚀 Performance Improvements

### Compilation Performance
- **Efficient test detection:** Fast identification of test methods during parsing
- **Optimized build modes:** Separate compilation paths avoid unnecessary overhead
- **Smart dependency loading:** testOnly dependencies excluded from production builds

### Test Execution Performance  
- **Direct test invocation:** Efficient test method execution without reflection overhead
- **Minimal runtime overhead:** Test framework integrated into compiler with no external dependencies
- **Fast test selection:** Efficient filtering of specific tests or classes

### Development Experience
- **Instant feedback:** Quick compilation and test execution
- **Clear diagnostics:** Immediate error messages for invalid test syntax
- **Flexible workflows:** Run tests selectively during development

## 🔮 What's Next

### Future Enhancements (Potential v0.6.4+)
- **Assertion library:** Built-in assertion functions for common test patterns
- **Setup/Teardown:** Test lifecycle methods for initialization and cleanup
- **Test fixtures:** Shared test data and configuration support
- **Mocking framework:** Mock object support for isolated testing
- **Code coverage:** Built-in code coverage analysis and reporting
- **Parallel test execution:** Run tests concurrently for faster execution

### Community Feedback
- Unit testing framework completes the essential developer tooling
- Enables test-driven development (TDD) workflows in AmLang
- Provides professional testing capabilities for production projects
- Maintains AmLang's commitment to developer experience and code quality

## 📋 Migration Guide

### From v0.6.2 to v0.6.3
- **100% backward compatible:** All existing code continues to work unchanged
- **New feature available:** Unit testing framework can be used immediately
- **No breaking changes:** Existing build commands and workflow unchanged
- **Optional adoption:** Testing framework is opt-in for projects

### Recommended Updates
1. **Create tests directory** in your project root alongside `src/`
2. **Add test files** with `.aml` extension in `tests/` directory
3. **Use `test` keyword** instead of `fun` for test methods
4. **Run tests** with `amlc test . -bt [target]` command

### Example Migration
```bash
# Before v0.6.3 - manual testing only
java -jar amlc-0.6.2.jar build . -bt native
java -jar amlc-0.6.2.jar run . -bt native

# After v0.6.3 - add unit testing
mkdir tests
# Create test files in tests/ directory
java -jar amlc-0.6.3.jar test . -bt native
java -jar amlc-0.6.3.jar build . -bt native
java -jar amlc-0.6.3.jar run . -bt native
```

### Development Workflow
- **TDD approach:** Write tests first, then implement features
- **Continuous testing:** Run tests frequently during development
- **CI/CD integration:** Incorporate test command into build pipelines
- **Test coverage:** Gradually add tests for existing code

## 📚 Documentation Updates

### New Documentation
- **Unit testing guide:** Complete testing framework documentation in README
- **Test examples:** Working examples in `examples/unit-testing/` directory
- **Command reference:** Updated CLI documentation with test command
- **Release notes:** Complete feature documentation and examples

### Updated Documentation
- **README.md:** Added comprehensive unit testing section
- **Version history:** Updated to include v0.6.3 features
- **Project structure:** Documented `tests/` directory and `builds/test-bin/`
- **CLI usage:** Added test command examples and options

---

**AmLang v0.6.3** establishes AmLang as a complete development platform with professional testing capabilities, enabling test-driven development and ensuring code quality for production applications while maintaining our commitment to simplicity, performance, and developer experience.
