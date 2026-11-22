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

**Concatenation with `+`:**
`+` joins two Strings and nothing else. There is no implicit conversion to String, so
`"a" + i` (and `i + "a"`) with an Int, Bool, enum, object or nullable value is a compile
error that names both types. Use a template or `toString()`:
```amlang
var i = 1
var j = 2
var bad = "a" + i                 // error: `+` can't join String and Int: ...
var ok1 = "a${i}${j}"             // a12
var ok2 = "a" + i.toString() + j.toString()   // a12
var s = "x"
s += i.toString()                 // `s += i` is the same error as `s + i`
```
Both operands of `+` are null-checked at run time: a `String?` or a null array element on
either side throws a catchable `Null reference` instead of crashing. The
compile-time rule looks at the type only, so `"a" + names[i]` compiles.

**A literal `$`:**
`$` followed by something that can't start a name (a digit, a space, the end of the
string) is an ordinary `$`. Write `\$` for a `$` that would otherwise start an
interpolation:
```amlang
var price = "cost $5"        // cost $5
var snippet = "\${1:name}"    // ${1:name} (no interpolation)
var literal = "\$name"        // $name
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

A decimal literal is an `Int` unless it has a type suffix: `L` (Long), `S` (Short),
`B` (Byte), `UL`, `UI`, `US`, `UB` (the unsigned types): `255UB`, `100L`.

A hex literal takes no suffix. It gets its type from where it is used:

```amlang
var mask: UInt = 0xFFFFFFFF       // UInt
var esc: UByte = 0x1B             // UByte 27 (B is a digit)
if (b == 0xFA) { }                // compared as b's type
var big = 0x100000000             // too wide for 32 bits: Long
var all = 0xffffffffffffffff      // too wide for a Long: ULong
var flags = 0x80000000 as UInt    // no context: say the type with `as`
```

With no context and no `as`, a hex literal that fits 32 bits is an `Int` holding that bit
pattern (`0xFFFFFFFF` is `-1`).

A type suffix on a hex literal (`0xFFUI`, `0xffUB`, `0x10L`) is an error. `B` and `b` are
always digits: `0x1B` is 27. (Before 0.16.0 an uppercase `B` at the end was the Byte
suffix, so `0x1B` was the Byte 1.)

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

`++` and `--` step a local, a field, a static, a struct member or an array
element, also an `Int?` (a null one throws "Null reference"). Used as a value,
`x++` is the old value and `++x` the new one, anywhere an expression goes:
`while (d-- > 0)`, `var s = d++ + j`, `arr[k++]`, `d++.toString()`. A prefix
operator binds tighter than any binary operator (`++i + 1` is `(++i) + 1`). An
operator at the start of the next line is a new statement: `var a = i` then
`++i` on the next line steps `i`, not `a`.

#### Integer division by zero

What integer `/` and `%` (and `/=`, `%=`) do with a zero divisor depends on
whether the build is *checked*:

- **Checked** (the default for `amlc test`): the divisor is checked first. A
  zero divisor throws `ArithmeticException` with the message
  `Division by zero`, and a signed `minValue / -1` or `minValue % -1` (the
  result doesn't fit) throws `ArithmeticException` with `Division overflow`.
  Every integer width, signed and unsigned, is checked. Since any division can
  then throw, `#noThrow` is ignored on AmLang functions in a checked build:
  a `#noThrow` function with an uncaught division compiles, and the exception
  reaches its caller.
- **Unchecked** (the default for `amlc build` and `amlc run`): plain C
  division with no check. Dividing by zero (or `minValue / -1`) gives an
  unspecified result, and the program may crash: x86 stops it with SIGFPE,
  68k AmigaOS with a "Division by zero" Guru, ARM64 returns 0 (`7 / 0` is 0,
  `7 % 0` is 7), and PowerPC returns garbage. The C compiler may also assume
  the divisor wasn't zero when it optimises the code around it.

So division by zero is a bug to find in testing, not a value to handle in a
release build: check the divisor yourself where it can be zero. A build
target's `checkedDivision: true` or `false` in `package.yml` overrides the
default either way (see [Compiler Usage](16-compiler-usage.md)).

```amlang
try {
    var share = total / count
} catch (e: ArithmeticException) {
    e.message.println()   // "Division by zero" in a checked build
}
```

A literal divisor other than 0 (and other than -1 for a signed type) is never
checked: `x / 2` and `x % 10` cost nothing. `Float` and `Double` division
follows IEEE 754 (`1.0 / 0.0` is infinity) and never throws.

### Comparison Operators
```amlang
==  // Equality
!=  // Inequality
<   // Less than
>   // Greater than
<=  // Less than or equal
>=  // Greater than or equal
```

`==` and `!=` on strings compare their characters (`equals`). `<`, `>`, `<=` and `>=` are not defined for strings and are a compile error; order strings with `compareTo`, which is negative, 0 or positive (byte-wise on UTF-8, so code point order):

```amlang
if (a.compareTo(b) < 0) { ... }
```

Comparing or combining a signed and an unsigned integer (`Int` with `UInt`, anything with `ULong`) is a warning: as in C, the signed value is converted to unsigned, so `-1 == 4294967295UI` is true. Convert one side with `as`. A non-negative literal on the signed side (`u < 10`) is fine.

### Logical Operators
```amlang
&&  // Logical AND
||  // Logical OR
!   // Logical NOT
```

### Precedence

From tightest to loosest:

| Operators | Groups |
|---|---|
| prefix `!` `-`, `as`, `is` | bind to the operand next to them |
| `*` `/` `%` | left: `a - b - c` is `(a - b) - c` |
| `+` `-` | left |
| `<<` `>>` | left |
| `<` `<=` `>` `>=` | left |
| `==` `!=` | left |
| `&&` `\|\|` | to the right (below) |

So `a + b == c` is `(a + b) == c`, `"Am.Lang." + name != full` compares the concatenation, and `a < b && c < d` is `(a < b) && (c < d)`.

Two groupings differ from C, Java and Kotlin; write the parentheses where it matters:

- `&&` and `||` nest to the right whichever comes first: `a && b || c` is `a && (b || c)` (C: `(a && b) || c`), and `a || b && c` is `a || (b && c)`.
- `&`, `|`, `^` and `??` have no precedence of their own: each takes the operand just before it and the whole rest of the expression. `a + b & c` is `a + (b & c)`, `x == y & z` is `x == (y & z)`, `a & b + c` is `a & (b + c)`, and `s ?? "x" + "y"` is `s ?? ("x" + "y")`.

### Assignment Operators
```amlang
=   // Assignment
+=  // Add and assign
-=  // Subtract and assign
*=  // Multiply and assign (since v0.15.0)
/=  // Divide and assign (since v0.15.0)
%=  // Remainder and assign (since v0.15.0)
&=  // Bitwise AND and assign (since v0.15.0)
|=  // Bitwise OR and assign
^=  // Bitwise XOR and assign (since v0.15.0)
```

The right side is a whole expression: `x += a + b` adds `a + b`. A compound assignment works on locals, properties, statics, array elements and nullable primitives (`Int?`: a null value throws a null-reference exception). On a class with an operator function, `v *= 3` means `v = v * 3`. `%`, `&`, `|`, `^` and their assignment forms are for integer types; on `Float` / `Double` they are a compile error.

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
// For loop: `to` includes the end, `until` stops before it
for (i = 0 to 10) {
    // i = 0, 1, ..., 10
}
for (i = 0 until list.getSize()) {
    // i = 0 .. size - 1
}

// Every element of a collection
each(list, item) {
    // statements
}

// While loop (based on patterns in test files)
while (condition) {
    // statements
}
```

### When Statement
```amlang
when (subject) {
    is Circle -> area = subject.r * subject.r   // smart cast to Circle
    1, 2 -> small = true                         // value list
    else -> other = true
}

when {
    x < 0 -> sign = -1
    else -> sign = 1
}
```

## Declaration Syntax

### Variable Declarations
```amlang
// Mutable variable
var name: Type = value

// Immutable variable (constant)
const name: Type = value

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