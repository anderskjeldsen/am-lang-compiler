# AmLang Compiler v0.6.2 - Feature Overview

**Release Date:** September 26, 2025  
**Major Release:** Switch-Case-Default Statement Implementation

## 🎉 Major New Features

### 1. **Switch-Case-Default Statements** 🔀
Complete C-style switch statement implementation with AmLang enhancements:

- **Intuitive syntax:** `switch (expression) { case value: ... default: ... }`
- **Type safety validation:** Compile-time checking that case values are compatible with switch type
- **Object-aware equality:** Proper comparison for strings, objects, and primitives using runtime functions
- **Modern architecture:** Built on CodeBlock expressions for maintainable code generation
- **Comprehensive error handling:** Detailed validation with clear error messages

**Basic Example:**
```amlang
var status = 200
switch (status) {
    case 200:
        var response = "OK"
    case 404: 
        var response = "Not Found"
    case 500:
        var response = "Server Error"  
    default:
        var response = "Unknown Status"
}
```

**Character Switching:**
```amlang
var operation = '+'
switch (operation) {
    case '+':
        result = a + b
    case '-':
        result = a - b
    case '*':
        result = a * b
    default:
        result = 0
}
```

**String-based Logic:**
```amlang
var command = "build"
switch (command) {
    case "build":
        compileProject()
    case "test":
        runTests()
    case "clean":
        cleanBuild()
    default:
        showHelp()
}
```

## 🔧 Technical Improvements

### Compiler Architecture
- **Enhanced parsing:** New `ControlFlowExpressionParser.parseSwitch()` method with comprehensive syntax support
- **Robust type binding:** Advanced type compatibility validation using `Type.canCastTo()` for safety
- **Smart error reporting:** Detailed validation messages for structural and type errors

### Language Processing  
- **Keywords added:** SWITCH, CASE, DEFAULT integrated into language grammar
- **Parser integration:** Seamlessly integrated into main expression parsing pipeline  
- **Binding validation:** Prevents case statements after default clause, ensures type compatibility
- **Code generation:** Generates clean if/elseif/else C code with proper object equality handling

### Code Generation Quality
- **Object equality support:** Uses AmLang runtime `__object_equals()` and `__any_equals()` functions
- **Type-aware comparisons:** Optimized comparison code for primitives vs objects
- **Memory efficient:** Proper variable scoping within case code blocks
- **C compatibility:** Generates clean, readable C code that integrates with existing runtime

### Developer Experience
- **Comprehensive validation:** Catches type mismatches, structural errors, and ordering issues at compile time
- **Clear error messages:** Detailed diagnostics for common switch statement mistakes  
- **Modern syntax support:** Familiar C-style syntax with AmLang type safety enhancements
- **Complete documentation:** Full grammar specification and usage examples

## 🧪 Quality Assurance

### Test Coverage
- **Unit tests:** Complete test suite in `SwitchTest.kt` covering all major scenarios
- **Integration tests:** End-to-end compilation, binding, and validation testing
- **Error validation tests:** Comprehensive testing of type mismatches and structural errors
- **Architecture verification:** Tests ensuring proper CodeBlock structure usage

### Validation Testing
- **Type compatibility:** Tests for valid and invalid case value types
- **Structural validation:** Tests for case/default ordering rules
- **Error handling:** Tests for malformed syntax and edge cases  
- **Code generation:** Tests verifying correct C code output

### Example Programs
- **Basic switch:** Simple integer value switching (`logic/switch1.aml`)
- **Character switch:** Character-based conditional logic examples
- **Error cases:** Test cases for validation error scenarios
- **Complex scenarios:** Multi-type switching with proper error handling

## 📦 Installation & Usage  

### Updated CLI Commands
```bash
# Compile a project with switch statements
java -jar amlc-0.6.2.jar build /path/to/project -bt [target]

# All existing options remain unchanged
-cores=X      # Parallel compilation  
-rl           # Runtime logging
-cl           # Conditional logging
-ll [0-5]     # Log level control
-rdc          # Debug comments in output
```

### Switch Statement Syntax
```amlang
switch (expression) {
    case value1:
        // statements in code block
    case value2:
        // statements in code block  
    default:
        // default statements
}
```

### Integration Examples
```amlang
namespace GameLogic {
    class GameState {
        fun handleInput(key: Char) {
            switch (key) {
                case 'w':
                    moveUp()
                case 's':
                    moveDown() 
                case 'a':
                    moveLeft()
                case 'd':
                    moveRight()
                default:
                    // ignore unknown input
            }
        }
    }
}
```

## 🚀 Performance Improvements

### Compilation Performance
- **Efficient parsing:** Fast switch statement recognition and processing
- **Optimized binding:** Smart type checking with minimal overhead
- **Code generation:** Clean C output without unnecessary complexity

### Runtime Performance  
- **Efficient comparisons:** Optimized equality checking for different value types
- **Memory usage:** Proper variable scoping prevents memory leaks in case blocks
- **C integration:** Generated code integrates seamlessly with AmLang runtime

### Development Experience
- **Fast validation:** Quick compile-time error detection for switch issues
- **Clear diagnostics:** Immediate feedback on type and structural problems
- **Incremental compilation:** Switch changes don't require full recompilation

## 🔮 What's Next

### Future Enhancements (Potential v0.6.3+)
- **Multiple case values:** `case 1, 2, 3:` syntax for multiple values per case
- **Range cases:** `case 1 to 10:` syntax for numeric range matching
- **Pattern matching:** Advanced pattern-based case matching

### Community Feedback
- Switch statements complete the core control flow feature set
- Enables complex state machine and command processing implementations
- Provides familiar syntax for developers from C/Java backgrounds

## 📋 Migration Guide

### From v0.6.1 to v0.6.2
- **100% backward compatible:** All existing code continues to work unchanged
- **New feature available:** Switch statements can be used immediately  
- **No breaking changes:** Existing control flow statements (if, while, for) unchanged
- **Optional adoption:** Switch statements are opt-in for new development

### Recommended Updates
1. **Replace complex if-else chains** with switch statements where appropriate:
   ```amlang
   // Before (v0.6.1)
   if (status == 200) {
       response = "OK"
   } else if (status == 404) {
       response = "Not Found"  
   } else if (status == 500) {
       response = "Server Error"
   } else {
       response = "Unknown"
   }
   
   // After (v0.6.2)
   switch (status) {
       case 200:
           response = "OK"
       case 404:
           response = "Not Found"
       case 500:
           response = "Server Error"
       default:
           response = "Unknown"
   }
   ```

2. **Use switch for discrete value comparisons** to improve code readability
3. **Leverage type safety** to catch case value mismatches at compile time

### Development Workflow
- **IDE integration:** Switch statements work with existing AmLang development tools
- **Testing:** All existing testing frameworks work with switch-containing code
- **Build process:** No changes to existing build configurations required

## 📚 Documentation Updates

### New Documentation
- **SWITCH_IMPLEMENTATION.md:** Detailed implementation guide for contributors
- **syntax-grammar.md:** Updated grammar specification including switch statements
- **Release notes:** Complete feature documentation and examples

### Updated Documentation
- **README.md:** Updated version references and feature highlights
- **Command-line usage:** Updated CLI documentation for v0.6.2
- **Examples:** New example programs demonstrating switch statement usage

---

**AmLang v0.6.2** completes the essential control flow feature set, making AmLang a fully-featured programming language suitable for complex application development while maintaining our commitment to type safety, performance, and developer experience.