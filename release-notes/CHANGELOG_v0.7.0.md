# AmLang Compiler v0.7.0 - Release Documentation

**Release Date:** November 2025  
**Major Release:** Feature Toggles, Float/Double Support, Linting, and Documentation System

## 🎉 Major New Features

### 1. **Feature Requirement System (#require directives)** 🎯

**Complete conditional compilation system for managing feature-gated code:**

#### Core Implementation:
- **#require directive**: Parser-level feature requirements  
- **#requireNot directive**: Exclusion-based feature requirements
- **Function-level features**: Functions can require specific features
- **Package feature management**: Per-package feature support configuration

#### Syntax Examples:
```amlang
// Platform-specific implementations
namespace Graphics {
    #require opengl
    class Renderer {
        fun initialize() {
            OpenGL.initContext()
        }
        
        fun drawTriangle(vertices: Array<Vector3>) {
            OpenGL.drawArrays(vertices)
        }
    }

    #require directx
    class Renderer {
        fun initialize() {
            DirectX.createDevice()
        }
        
        fun drawTriangle(vertices: Array<Vector3>) {
            DirectX.drawPrimitive(vertices)
        }
    }
}

// Exclude classes when feature not available
namespace AdvancedMath {
    #require vectorExtensions
    class VectorProcessor {
        // Only available when vector extensions are supported
        fun simdMultiply(a: Vector4, b: Vector4): Vector4 {
            return SIMD.multiply(a, b)
        }
    }
}
```

#### Technical Implementation:
- **Parser Support**: `CodeParser.kt` recognizes `#require` and `#requireNot` directives
- **Feature Filtering**: Classes/functions are excluded during compilation if features not available
- **Package Declaration**: Features offered by a package defined in `package.yml` under `availableFeatures`
- **Dependency Selection**: Dependencies can specify which features they want to use from other packages
- **Runtime Management**: `Runtime.kt` manages package feature sets with `setPackageSupportedFeatures()`
- **Error Handling**: Clear error messages when required features are missing

#### Use Cases:
- **Platform-Specific Code**: Different implementations for OpenGL vs DirectX, Linux vs Windows
- **Hardware Capabilities**: SIMD optimizations, GPU compute shaders, ARM vs x86 features
- **Library Variants**: Different implementations based on available system libraries
- **API Versioning**: Different class implementations for different API versions
- **Development Builds**: Debug-only classes and diagnostic tools

---

### 2. **Float and Double Type Support** 🔢

**Complete implementation of IEEE 754 floating-point numbers:**

#### New Primitive Types:
- **Float**: 32-bit floating-point numbers (suffix: `F`)
- **Double**: 64-bit floating-point numbers (suffix: `D` or no suffix)

#### Scientific Notation Support:
```amlang
namespace Example {
    class FloatDoubleDemo {
        static fun main() {
            // Basic float/double literals
            var f: Float = 3.14F
            var d: Double = 2.718281828
            
            // Scientific notation support
            var smallFloat: Float = 1.23e-4F    // 0.000123
            var largeDouble: Double = 6.02e23   // Avogadro's number
            var negativeExp: Double = 9.81e-2   // 0.0981
            
            // Arithmetic operations
            var sum: Double = f.toDouble() + d
            var product: Float = f * 2.0F
            var quotient: Double = d / f.toDouble()
        }
    }
}
```

#### Technical Implementation:
- **Multi-token Parsing**: `CodeParser.kt` handles complex float parsing (`parseFloatOrDoubleConstant()`)
- **Scientific Notation**: Parser recognizes `e`/`E` notation with positive/negative exponents
- **Constant Binding**: `ConstantBinder.kt` properly types Float/Double expressions
- **Type System Integration**: Full integration with AmLang's type system
- **C Code Generation**: `CRenderer.kt` generates appropriate C float/double code

#### Validation Features:
- **Type Safety**: Compile-time validation of float/double operations
- **Suffix Recognition**: `F` for Float, `D` for Double (optional)
- **Expression Evaluation**: Proper evaluation in mathematical expressions
- **toString() Support**: Automatic string conversion for output

---

### 3. **Code Linting System** 🔍

**Professional code quality and style enforcement:**

#### Core Linting Infrastructure:
- **`amlc lint` command**: Dedicated CLI command for code analysis
- **Configuration System**: `amlint.yaml` configuration files
- **Extensible Rules**: Modular linting rule system
- **Warning Reporting**: Non-blocking warnings with detailed messages

#### Linting Rules Implemented:
```yaml
# amlint.yaml configuration
namingConventions:
  classNamePattern: "^[A-Z][a-zA-Z0-9]*$"
  functionNamePattern: "^[a-z][a-zA-Z0-9]*$"
  variableNamePattern: "^[a-z][a-zA-Z0-9]*$"
  enforceClassNameCase: "PascalCase"
  enforceFunctionNameCase: "camelCase"
  enforceVariableNameCase: "camelCase"

codeStyle:
  maxLineLength: 120
  maxFunctionLength: 50
  maxParameterCount: 5
  requireBracesForSingleStatement: true
  forbidEmptyBlocks: false

bestPractices:
  requireDocumentationForPublicMethods: true
  forbidUnusedVariables: true
  enforceConstNaming: true
  requireNullChecks: true
```

#### Technical Implementation:
- **Linter Class**: `Linter.kt` implements rule checking logic
- **Configuration Loading**: `LintConfig.kt` loads YAML configuration
- **AST Analysis**: Traverses parsed code to check naming conventions
- **Pattern Matching**: Regex-based validation for naming patterns
- **Integration**: Runs after parsing/binding but before rendering

#### Supported Checks:
- **Naming Conventions**: PascalCase for classes, camelCase for functions/variables
- **Code Style**: Line length, function length, parameter count limits
- **Best Practices**: Documentation requirements, unused variable detection
- **Constructor Validation**: Special handling for primary constructor parameters

---

### 4. **Documentation Generation System** 📚

**Comprehensive API documentation with multiple output formats:**

#### Documentation Command:
```bash
# Generate documentation
amlc docs                              # Both JSON and Markdown
amlc docs -docformat json            # JSON only  
amlc docs -docformat md              # Markdown only
amlc docs -docout api-docs/          # Custom output directory
```

#### JavaDoc-Style Comment Support:
```amlang
namespace MyLibrary {
    /**
     * A calculator class that provides basic mathematical operations.
     * Supports addition, subtraction, multiplication, and division.
     * 
     * @author AmLang Team
     * @version 1.0
     */
    class Calculator {
        /**
         * Adds two numbers together.
         * @param a The first number
         * @param b The second number  
         * @return The sum of a and b
         */
        fun add(a: Int, b: Int): Int {
            return a + b
        }
    }
}
```

#### Output Formats:

**Structured Markdown**: Directory-based organization
```
docs/
├── index.md                    # Main documentation index
├── namespaces/
│   ├── MyLibrary/
│   │   ├── index.md           # Namespace overview
│   │   └── Calculator.md      # Class documentation
│   └── index.md               # Namespaces index
├── classes/
│   └── index.md               # All classes index
└── api-documentation.json     # Complete JSON API
```

**JSON Documentation**: Machine-readable API reference
```json
{
  "project": "MyProject",
  "version": "1.0.0",
  "namespaces": [
    {
      "name": "MyLibrary",
      "fullPath": "MyLibrary",
      "classes": [
        {
          "name": "Calculator",
          "documentation": "A calculator class...",
          "functions": [
            {
              "name": "add",
              "parameters": ["a: Int", "b: Int"],
              "returnType": "Int",
              "documentation": "Adds two numbers together."
            }
          ]
        }
      ]
    }
  ]
}
```

#### Technical Implementation:
- **Documentation Extraction**: `DocumentationExtractor.kt` extracts docs from compiled AST
- **Structured Export**: `StructuredMarkdownExporter.kt` creates organized directory structures
- **JSON Export**: `JsonDocumentationExporter.kt` produces machine-readable API docs
- **AST Integration**: Extracts documentation from parsed classes, functions, and namespaces
- **CLI Integration**: Built into main compiler with dedicated `docs` command

---

## 🔧 Technical Implementation Details

### Feature System Architecture:
- **Conditional Compilation**: Classes/functions excluded at compile-time based on features
- **Package-Level Configuration**: Features managed per package in dependency tree
- **Error Reporting**: Clear messages when required features are unavailable
- **Inheritance Support**: Feature requirements properly handled in class hierarchies

### Float/Double Parser Enhancement:
- **Multi-Token Recognition**: Handles complex patterns like `1.23e-4F`
- **Type Inference**: Automatic type detection based on suffix and context
- **Scientific Notation**: Full support for exponential notation with proper validation
- **Backward Compatibility**: Existing integer parsing unchanged

### Linting System Design:
- **Configuration-Driven**: Rules defined in external YAML files
- **Non-Blocking**: Linting warnings don't prevent compilation
- **Extensible**: Rule system designed for easy addition of new checks
- **AST-Based**: Operates on parsed abstract syntax tree for accuracy

### Documentation Architecture:
- **Multi-Format**: Single extraction with multiple export formats
- **Structured Output**: Organized directory structures for large codebases
- **AST-Driven**: Extracts documentation from compiled code structure
- **Template-Based**: Consistent formatting across generated documentation

---

## 📊 Feature Compatibility

### Backward Compatibility:
- **100% Compatible**: All existing v0.6.4 code continues to work unchanged
- **Optional Features**: New features are opt-in and don't affect existing code
- **CLI Extensions**: New commands don't interfere with existing workflows

### New Command Summary:
```bash
amlc lint                    # Run code linting with amlint.yaml
amlc docs                    # Generate API documentation
amlc docs -docformat json    # JSON documentation only
amlc docs -docformat md      # Markdown documentation only
```

### Configuration Files:
- **amlint.yaml**: Linting rules configuration (optional)
- **package.yml**: Extended with `availableFeatures` for feature management

---

## 🎯 Use Cases Enabled

### Enterprise Development:
- **Feature Flagging**: Professional feature toggle system for SaaS applications
- **Code Quality**: Automated linting for large development teams
- **API Documentation**: Professional documentation generation for libraries

### Cross-Platform Development:
- **Platform-Specific Features**: Conditional compilation for different platforms
- **Progressive Enhancement**: Basic features everywhere, premium features where supported
- **Scientific Computing**: Native float/double support for mathematical applications

### Developer Experience:
- **Professional Tooling**: IDE-quality linting and documentation
- **Configuration Management**: YAML-based configuration for team standards
- **Automated Workflows**: Documentation generation in CI/CD pipelines

---

**AmLang v0.7.0** represents a major maturity milestone, bringing enterprise-grade features, professional tooling, and enhanced language capabilities that position AmLang as a production-ready programming language for serious software development.