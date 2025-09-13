# AmLang Compiler v0.6.1 - Feature Overview

**Release Date:** September 11, 2025  
**Major Release:** Complete implementation of core language features

## 🎉 Major New Features

### 1. **String Interpolation Support** 🔥
Complete implementation of modern string interpolation with two syntaxes:

- **Simple variable interpolation:** `"Hello $name"`
- **Expression interpolation:** `"Result: ${x + y}"`
- **Automatic toString() calls:** Support for complex expressions and object interpolation
- **Mixed interpolation:** Multiple variables and expressions in a single string
- **Nested expressions:** `"Value: ${getValue(x * 2)} units"`

**Example:**
```amlang
var name = "World"
var x = 10, y = 20
var greeting = "Hello $name"
var calculation = "Result: ${x + y}"
var person = new Person("Alice", 25)
var intro = "Hi, I'm ${person.name} and I'm ${person.age} years old!"
```

### 2. **Array Initializers** 📚
Modern array initialization syntax:

- **Literal syntax:** `var arr: String[] = ["Hello", "World", "!"]`
- **Type safety:** Compile-time type checking for array elements
- **Mixed types:** Support for object arrays and primitive arrays
- **Memory efficient:** Optimized C code generation

**Example:**
```amlang
var numbers: Int[] = [1, 2, 3, 4, 5]
var names: String[] = ["Alice", "Bob", "Charlie"]
var mixed: Object[] = [person, "text", 42]
```

### 3. **Enhanced Loop Constructs** 🔄
Modern iteration with range-based loops:

- **Range syntax:** `for(i = 0 to 10)`
- **Type inference:** Automatic variable type detection
- **Nested scoping:** Proper variable scoping within loops
- **Continue support:** `continue` statement for loop control

**Example:**
```amlang
for(i = 0 to 10) {
    i.print()
}

for(j = 5 to 15) {
    var s = "hello"
    s.print()
}
```


## 📦 Installation & Usage

### Updated CLI Commands
```bash
# Compile a project
java -jar amlc-0.6.1.jar build /path/to/project -bt [target]

# New options in v0.6.1
-cores=X      # Parallel compilation (default: 4)
-rl           # Runtime logging
-cl           # Conditional logging  
-ll [0-5]     # Log level control
-rdc          # Debug comments in output
```

### Project Structure
```
my-project/
├── package.yml          # Project configuration
├── src/
│   └── main.aml        # AmLang source files
├── builds/             # Generated build files
└── dependencies/       # External dependencies
```

