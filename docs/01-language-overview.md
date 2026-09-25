# Language Overview

Am Lang is a modern object-oriented programming language designed for systems programming with a focus on cross-platform compatibility. It combines the power of low-level system programming with modern language features and safety guarantees.

For current installation, optimization flags, build targets, and migration guidance, see the [v0.13.0 README](../README.md).

## Design Philosophy

Am Lang is designed with these core principles:

- **Cross-Platform Compatibility**: Compile to optimized C code for maximum portability
- **Memory Safety**: Automatic reference counting with optional memory leak tracking
- **Modern Syntax**: Clean, expressive syntax inspired by Kotlin and C#
- **Native Interoperability**: Seamless integration with existing C libraries
- **Performance**: Zero-overhead abstractions and efficient code generation

## Key Features

### Object-Oriented Programming
- Classes with single inheritance
- Interfaces for multiple inheritance of behavior
- Polymorphism and method overriding
- Access modifiers for encapsulation


### Modern Language Features
- String interpolation with `$variable` and `${expression}` syntax
- Automatic toString() method calls in string contexts
- Type inference for cleaner code
- Explicit nullable object and primitive types (`T?`), safe calls, and null-coalescing

### Memory Management
- Automatic reference counting
- Optional memory leak tracking for debugging
- Manual memory management when needed for performance

### Concurrency
- Built-in threading support
- Suspend functions for asynchronous programming
- Thread-safe primitives

### Type System
- Strong static typing
- Explicit nullable object and primitive types (`T?`), safe calls, and null-coalescing
- Type inference for cleaner code
- Primitive types with automatic boxing/unboxing

### Native Integration
- Direct C library bindings
- Native classes for hardware abstraction
- Platform-specific code organization

## Language Characteristics

### File Extension
AmLang source files use the `.aml` extension.

### Case Sensitivity
Am Lang is case-sensitive. `MyClass` and `myclass` are different identifiers.

### Comments
Am Lang supports both single-line and multi-line comments:

```amlang
// Single-line comment

/*
 * Multi-line comment
 * spanning multiple lines
 */
```

### Compilation Model
Am Lang source code is compiled to C code, which is then compiled to native machine code using a C compiler like GCC. This approach provides:

- Maximum portability across platforms
- Access to mature C toolchains
- Ability to link with existing C libraries
- Predictable performance characteristics

## Hello World Example

Here's a simple "Hello, World!" program in Am Lang:

```amlang
namespace HelloWorld {
    class Main {
        import Am.Lang

        static fun main() {
            "Hello, World!".println()
        }
    }
}
```

This example demonstrates:
- Namespace declaration for code organization
- Class definition
- Static function declaration
- String literal with method call

## Comparison to Other Languages

### Similar to Kotlin/Java
- Object-oriented with classes and interfaces
- Strong static typing
- Familiar syntax for variable declarations

### Similar to C#
- Properties and methods
- Namespace organization
- String interpolation

### Similar to C/C++
- Compiles to native code
- Direct memory access when needed
- Native library integration

### Unique Features
- Compiles to C as intermediate representation
- Built-in threading with suspend functions
- Automatic reference counting memory management
- Cross-platform build targets including legacy systems (Amiga)

## Next Steps

- Learn about [Syntax and Grammar](./02-syntax-grammar.md)
- Explore [Keywords Reference](./03-keywords.md)
- Understand the [Type System](./04-type-system.md)