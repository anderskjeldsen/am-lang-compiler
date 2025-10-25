# AmLang Unit Testing Framework Example

This example demonstrates AmLang's comprehensive built-in unit testing framework with dedicated syntax, separate build system, and professional test execution.

## Project Structure

```
examples/unit-testing/
├── package.yml                    # Project configuration
├── src/
│   └── am-lang/
│       ├── base.aml              # Base AmLang classes
│       └── Example/
│           └── Calculator.aml    # Example Calculator class to test
├── tests/
│   └── CalculatorTest.aml        # Test classes with test functions
└── builds/
    ├── bin/                      # Regular application builds
    └── test-bin/                 # Test executable builds (generated)
```

## Running Tests

AmLang's testing framework provides flexible test execution options:

```bash
# Navigate to the example directory
cd examples/unit-testing

# Run all tests
amlc test . -bt native

# Run specific test class
amlc test . -bt native -tests CalculatorTest

# Run specific test methods
amlc test . -bt native -tests "CalculatorTest testAddition"

# Run multiple tests/classes
amlc test . -bt native -tests "CalculatorTest testSubtraction"

# Or from the compiler root directory
cd ../../
java -jar target/amlc-0.6.3.jar test examples/unit-testing -bt native
```

## Test Syntax

Tests are defined using the `test` keyword with strict validation rules:

```amlang
namespace ExampleTests {
    class CalculatorTest {
        import Am.Lang
        import Example
        
        test testAddition() {           // No parameters allowed
            var calculator = new Calculator()
            var result = calculator.add(5, 3)
            if (result == 8) {
                "Calculator addition test passed".println()
            } else {
                "Calculator addition test failed".println()
            }
        }
        
        test testSubtraction() {
            var calculator = new Calculator()
            var result = calculator.subtract(10, 4)
            if (result == 6) {
                "Calculator subtraction test passed".println()
            }
        }
        
        test testDivisionByZero() {
            var calculator = new Calculator()
            var result = calculator.divide(10, 0)
            // Test edge cases - handle expected behavior
        }
    }
}
```

## Key Features Demonstrated

### ✅ **Test Syntax and Validation**
- **`test` keyword**: Define test functions with `test myTest() { ... }` syntax
- **No parameters**: Test functions cannot accept parameters for consistency
- **Parentheses required**: Must use `()` even with no parameters
- **Directory restriction**: `test` keyword only allowed in `tests/` directory

### ✅ **Build System Integration**
- **Separate makefiles**: Tests use `{platform}.test.makefile` files
- **Isolated builds**: Test executables in `builds/test-bin/` directory
- **Clean separation**: Production and test builds completely isolated

### ✅ **Test Execution Features**
- **Professional output**: Clear `[STARTING]`, `[PASSED]`, `[FAILED]` indicators
- **Test selection**: Run all tests, specific classes, or individual methods
- **Instance handling**: Test methods receive proper class instances
- **Error handling**: Tests wrapped with exception handling

### ✅ **Development Workflow**
- **Import system**: Test classes can import and use source classes
- **Proper testing**: Tests call actual class methods (not compiler operators)
- **Edge case testing**: Demonstrates testing error conditions
- **Clear output**: Easy to see which tests started and completed

## Expected Output

When running tests, you'll see professional output like:

```
=== AmLang Test Runner ===

=== Running all tests ===

[STARTING] CalculatorTest.testAddition
Calculator addition test passed
[PASSED] CalculatorTest.testAddition

[STARTING] CalculatorTest.testSubtraction
Calculator subtraction test passed
[PASSED] CalculatorTest.testSubtraction

[STARTING] CalculatorTest.testMultiplication
Calculator multiplication test passed
[PASSED] CalculatorTest.testMultiplication

=== All tests completed ===

=== Test execution completed ===
```

## testOnly Dependencies

This example also demonstrates how to use test-specific dependencies that only load during test mode:

```yaml
# package.yml (if using test-specific dependencies)
dependencies:
  - id: "test-utils"
    type: "git-repo"
    url: "https://github.com/example/test-utils.git"
    testOnly: true   # Only loaded during test mode, not build mode
```