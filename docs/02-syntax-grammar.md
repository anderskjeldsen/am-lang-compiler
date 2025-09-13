# Syntax and Grammar

This document describes the fundamental syntax and grammar rules of the Am Lang programming language.

## Basic Syntax Rules

### Identifiers
Identifiers in Am Lang must:
- Start with a letter (a-z, A-Z) or underscore (_)
- Contain only letters, digits, and underscores
- Be case-sensitive

Valid identifiers:
```amlang
myVariable
MyClass
_privateField
variable123
```

Invalid identifiers:
```amlang
123variable  // Cannot start with digit
my-variable  // Hyphen not allowed
class        // Reserved keyword
```

### Whitespace
- Whitespace (spaces, tabs, newlines) is generally ignored except for line termination
- Indentation is not significant (unlike Python)
- Multiple statements can be on the same line if separated by appropriate delimiters

### Line Termination
- Statements are generally terminated by newlines
- Semicolons are optional but can be used to separate statements on the same line
- Block statements use braces `{}` to group multiple statements

## Literals

### String Literals
String literals are enclosed in double quotes:
```amlang
var message = "Hello, World!"
var path = "C:\\Users\\Example"
var multiline = "This is a long string that " +
                "spans multiple lines"
```

#### String Interpolation
Am Lang supports string interpolation for embedding expressions within string literals:

**Variable Interpolation:**
Use `$variableName` to insert variable values:
```amlang
var name = "Alice"
var greeting = "Hello $name!"  // Result: "Hello Alice!"
```

**Expression Interpolation:**
Use `${expression}` for more complex expressions:
```amlang
var x = 10
var y = 20
var result = "The sum is ${x + y}"  // Result: "The sum is 30"

var person = new Person("Bob", 25)
var intro = "Hi, I'm ${person.name} and I'm ${person.age} years old!"
```

**Automatic toString() Calls:**
Objects are automatically converted to strings using their `toString()` method:
```amlang
class Person(var name: String, var age: Int) {
    fun toString(): String {
        return "Person(${name}, ${age})"
    }
}

var person = new Person("Charlie", 30)
var description = "User: $person"  // Calls person.toString()
```

### Character Literals
Character literals use single quotes and create UShort values:
```amlang
var letter: UShort = 'A'
var newline: UShort = '\n'
```

### Integer Literals
```amlang
var decimal = 42
var hex = 0xFF
var binary = 0b1010
var long = 1234L
```

### Boolean Literals
```amlang
var isTrue = true
var isFalse = false
```

### Null Literal
```amlang
var nullable: Int? = null
```

## Operators

### Arithmetic Operators
```amlang
+   // Addition
-   // Subtraction
*   // Multiplication
/   // Division
%   // Modulo
++  // Increment
--  // Decrement
```

### Comparison Operators
```amlang
==  // Equality
!=  // Inequality
<   // Less than
>   // Greater than
<=  // Less than or equal
>=  // Greater than or equal
```

### Logical Operators
```amlang
&&  // Logical AND
||  // Logical OR
!   // Logical NOT
```

### Assignment Operators
```amlang
=   // Assignment
+=  // Add and assign
-=  // Subtract and assign
*=  // Multiply and assign
/=  // Divide and assign
```

### Member Access
```amlang
.   // Member access
?.  // Safe member access (null-safe)
```

## Control Flow Syntax

### If Statements
```amlang
if (condition) {
    // statements
}

if (condition) {
    // statements
} else {
    // statements
}

if (condition1) {
    // statements
} else if (condition2) {
    // statements
} else {
    // statements
}
```

### Loops
```amlang
// For loop
for (i in 0 to 10) {
    // statements
}

// While loop (based on patterns in test files)
while (condition) {
    // statements
}
```

## Declaration Syntax

### Variable Declarations
```amlang
// Mutable variable
var name: Type = value

// Immutable variable (constant)
const var name: Type = value

// Type inference
var name = value

// Nullable type
var nullable: Type? = null
```

### Function Declarations
```amlang
// Basic function
fun functionName(param1: Type1, param2: Type2): ReturnType {
    return value
}

// Function with no return value
fun functionName(param: Type) {
    // statements
}

// Static function
static fun functionName(): ReturnType {
    return value
}

// Suspend function
suspend fun asyncFunction(): ReturnType {
    return value
}
```

### Class Declarations
```amlang
// Basic class
class ClassName {
    // class body
}

// Class with parameters
class ClassName(param1: Type1, param2: Type2) {
    // class body
}

// Class with inheritance
class ChildClass : ParentClass {
    // class body
}

// Native class
native class NativeClass {
    // native methods
}
```

### Interface Declarations
```amlang
interface InterfaceName {
    fun methodName(): ReturnType
}
```

### Namespace Declarations
```amlang
namespace NamespaceName {
    // namespace content
}

// Nested namespaces
namespace Outer.Inner {
    // nested namespace content
}
```

## String Interpolation

Am Lang supports string interpolation using `${}` syntax:
```amlang
var name = "Alice"
var age = 25
var message = "Hello, I'm ${name} and I'm ${age} years old"
```

## Import Statements

```amlang
import NamespaceName.ClassName
import Namespace.SubNamespace
```

## Block Structure

Am Lang uses braces `{}` to define code blocks:
```amlang
namespace MyNamespace {
    class MyClass {
        fun myFunction() {
            if (condition) {
                // nested block
            }
        }
    }
}
```

## Grammar Production Rules

The basic grammar structure follows this hierarchy:

```
Program -> Namespace*
Namespace -> 'namespace' Identifier '{' ClassDeclaration* '}'
ClassDeclaration -> Modifiers? 'class' Identifier Inheritance? '{' ClassMember* '}'
ClassMember -> FieldDeclaration | MethodDeclaration | ImportStatement
MethodDeclaration -> Modifiers? 'fun' Identifier ParameterList ReturnType? Block
ParameterList -> '(' (Parameter (',' Parameter)*)? ')'
Parameter -> 'var'? Identifier ':' Type
Type -> Identifier ('?')?
Block -> '{' Statement* '}'
Statement -> ExpressionStatement | IfStatement | VariableDeclaration | ReturnStatement
```

## Reserved Characters

The following characters have special meaning in Am Lang:
- `{}` - Block delimiters
- `()` - Parameter lists, expression grouping
- `[]` - Array access
- `.` - Member access
- `,` - Parameter/argument separator
- `:` - Type annotation
- `=` - Assignment
- `?` - Nullable type marker
- `"` - String delimiter
- `'` - Character delimiter
- `//` - Single-line comment
- `/*` `*/` - Multi-line comment delimiters

## Next Steps

- Learn about specific [Keywords](./03-keywords.md)
- Understand the [Type System](./04-type-system.md)
- Explore [Variables and Constants](./05-variables-constants.md)