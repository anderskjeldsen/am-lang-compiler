# AmLang v0.10.0 Release Notes

**Release Date:** April 28, 2026

## New Features

### 1. `inline` Functions

A new `inline` modifier on functions causes calls to be expanded directly into the caller's body in generated C, rather than emitted as regular function calls.

**Example:**
```amlang
class Calculator {
    inline fun double(value: Int): Int {
        return value + value
    }

    fun apply(x: Int): Int {
        return this.double(x)   // expanded inline at this call site
    }
}
```

**Benefits:**
- Zero call-site overhead for small helpers.
- GCC sees the expanded form and can constant-fold across the boundary.
- A natural fit for type-parameterized math, accessors, and adapters that should compile to nothing.

Inline functions can only be called directly — using one as a value or function reference produces a clear validation error. Inline is also allowed inside `struct` (since structs are value types and don't participate in virtual dispatch).

### 2. `#implementationPlatforms` Directive

A class-level directive declares which platforms need their own per-platform native stub. It goes before a `native class`, alongside `#requireFeature`.

**Example:**
```amlang
namespace Am.Threading {

    #implementationPlatforms "libc", "amigaos", "morphos-ppc"
    native class Thread(var runnable: Runnable) {
        native fun start()
        native fun join()
        native static fun getCurrent()
        native static fun sleep(milliseconds: Long)
    }
}
```

**Behavior:**
- Without the directive, only base platforms get a generated stub and derived platforms inherit the closest ancestor's implementation.
- With the directive, exactly the listed platforms get stubs. Each listed ID must match a platform defined in the package hierarchy.
- A class can therefore share a `libc` implementation across linux/macos/aros while providing first-class AmigaOS and MorphOS implementations side-by-side.

This unlocks the multi-platform native model that `am-lang-core`'s `Thread`, `Process`, `Date`, and `DateTime` now use.

### 3. `init { }` Blocks

Classes can now have an `init { }` block that runs as part of object construction, after the primary constructor and after body-declared property defaults.

**Example:**
```amlang
class Person(private var firstName: String, private var lastName: String) {
    private var fullName: String

    init {
        this.fullName = this.firstName + " " + this.lastName
    }

    fun getFullName(): String {
        return this.fullName
    }
}
```

**Why this is useful:**
- Computed state that depends on constructor parameters can be set without writing an explicit constructor body.
- Works with generics — the `init` body can reference type parameters and allocate `new T<...>(...)`:
  ```amlang
  class Wrapper<T>(var value: T) {
      private var dapper: Dapper<T>
      init {
          this.dapper = new Dapper<T>(this.value)
      }
  }
  ```
- Composes through inheritance: each class's `init` runs in base-to-derived order, so derived `init` blocks see fully-set base state.

Internally, `init { }` expressions are appended to `_init_instance` and that function is now called *after* the primary constructor, eliminating the previous separate `_init_after_primary_constructor_internal` helper and a subtle ordering bug where the constructor's primitive-flag reset could clobber body-declared defaults.

### 4. `const propName: Type` Property Syntax

Class properties now accept the bare `const propName: Type` form alongside the original `const var propName: Type`. Both are accepted, so existing code keeps compiling.

## Improvements

### Struct Value Equality

`==` and `!=` on struct values now compare fields recursively rather than performing pointer identity. Nested structs are compared element-by-element via generated `_equals` helpers. See `CHANGELOG_v0.10.0.md` for the deeper write-up.

### Stronger Struct Boxing and Validation

- Struct-typed property boxing is registered more reliably as concrete `Struct<T>` variants — fewer corner cases around generic struct properties.
- Assignment validation for structs is tightened to align with non-null struct semantics.

## Bug Fixes

- Struct `==` / `!=` no longer behave like pointer identity checks.
- Writing to boxed struct members (`obj.structProp.x = ...`) now persists correctly.
- Multiple edge cases in struct boxing/unboxing code generation were stabilized.
- Inline calls with conditional early returns (`return` inside an `if` body) now resolve variables correctly. Nested code blocks inside an inline expansion previously lost their parent reference, causing variable lookup failures.
- Multiple calls to the same inline function within one method no longer produce duplicate C labels (`__exit_N`); each expansion now gets a unique label suffix derived from the call expression ID.
- The result variable for an inline call is now declared before the enclosing `{}` block so it stays in scope after the block closes (previously caused undeclared-variable C errors).
- `FunctionReferenceRenderer` no longer emits a typedef for inline functions, which would reference an undefined symbol.

## Upgrade Notes

- If you maintain a `native class` with platform-specific C in `src/native-c/<platform>/`, opt in with `#implementationPlatforms` to stop inheriting the base-platform stub. Native implementations are on class level, and can no longer be mixed between platforms and base platforms. am-lang libraries will be updated shortly. 
