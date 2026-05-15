# AmLang Compiler Changelog

All notable compiler changes are documented here.

## [0.10.0] - 2026-04-29

### Added
- Struct value equality now compares fields recursively (including nested structs).
- Additional unit tests for struct comparison and struct-property boxing behavior.
- Class properties now support bare `const propName: Type` syntax in addition to the original `const var propName: Type` form (both are accepted for backward compatibility).
- `inline` keyword for functions: inline functions are expanded at call sites in generated C rather than emitted as regular function calls, enabling zero-overhead abstraction and full GCC constant-folding through the expansion.
- `#implementationPlatforms` directive (placed before a `native class`, alongside `#requireFeature`) declares which platforms need their own per-platform native stub. Example: `#implementationPlatforms "libc", "amigaos", "morphos-ppc"` on `Am.Threading.Thread`. Without the directive, only base platforms get stubs and derived platforms inherit. With it, exactly the listed platforms get stubs — letting one native class share a `libc` implementation across linux/macos while providing custom AmigaOS and MorphOS implementations side-by-side.
- `init { }` block on classes runs as part of object construction, after the primary constructor and after body-declared property defaults. Lets a class derive computed state from its constructor parameters without writing an explicit constructor body — e.g. `class Person(private var firstName: String, private var lastName: String) { private var fullName: String; init { this.fullName = this.firstName + " " + this.lastName } }`. Works with generics (the `init` body can reference type parameters and allocate `new T<...>(...)`) and composes through inheritance: each class's `init` runs in base-to-derived order so derived `init` blocks see fully-set base state. Internally, `init { }` expressions are appended to `_init_instance` and that function is now called *after* the primary constructor, eliminating the previous separate `_init_after_primary_constructor_internal` helper and a subtle ordering bug where the constructor's primitive-flag reset could clobber body-declared defaults.

### Changed
- Struct-typed property boxing is registered more reliably as concrete `Struct<T>` variants.
- Assignment validation for structs tightened to align with non-null struct semantics.

### Fixed
- Struct `==` and `!=` no longer behave like pointer identity checks.
- Writing to boxed struct members (for example `obj.structProp.x = ...`) now persists correctly.
- Multiple edge cases in struct boxing/unboxing code generation were stabilized.
- Inline function calls with conditional early returns (`return` inside `if` body) now resolve variables correctly; nested code blocks inside an inline expansion were missing their parent reference, causing variable lookup failures.
- Multiple calls to the same inline function within one method no longer produce duplicate C labels (`__exit_N`); each expansion now gets a unique label suffix derived from the call expression ID.
- Result variable for an inline call is now declared before the enclosing `{}` block so it remains in scope after the block closes (previously caused undeclared-variable C errors).
- `FunctionReferenceRenderer` no longer emits a typedef for inline functions, which would reference an undefined symbol.

## [0.9.0] - 2026-03-14

### Added
- Named argument support in function calls.
- Broader support for struct-heavy patterns (nested structs, arrays, argument passing).

### Changed
- Type parsing and binding robustness improved across newer expression forms.
- Compiler diagnostics improved for ambiguous and invalid type scenarios.

### Fixed
- Primitive/null comparison edge cases.
- Return-without-value handling in relevant contexts.
- Static invocation correctness, overload resolution issues, and several expression-ordering bugs.
- Reference-counting and generated C stability issues in complex programs.

## [0.8.0] - 2025-12-26

### Added
- Enhanced `each` loop syntax with `in` keyword while preserving old syntax.
- Feature-based dependency selection support in package management.

### Changed
- Function pointer property handling improved for member invocation paths.
- Expression pipeline refactoring for cleaner generation paths.

### Fixed
- C generation issues around direct function-pointer property invocation.

## [0.7.0] - 2025-11

### Added
- Feature requirement directives (`#require`, `#requireNot`) for conditional compilation.
- Full Float/Double support including scientific notation handling.
- `amlc lint` command and configurable lint rule infrastructure.

### Changed
- Package-level feature management integrated into dependency resolution.
- Parser, binder, and runtime feature filtering paths expanded.

### Fixed
- Multiple type-binding and parsing edge cases tied to feature-gated code.

## [0.6.4] - 2025-10-25

### Added
- Built-in mock framework for tests (`mock` keyword).
- Scoped/nested mock handling with cleanup and state restoration.
- Native build automation scripts and multi-platform build profile support.
- Automated release pipeline improvements.

### Changed
- Test-mode behavior refined for mock syntax and execution flow.

### Fixed
- Mock state leakage and restoration-order issues in nested scenarios.

## [0.6.3] - 2025-10-03

### Added
- Built-in unit testing framework with `test` methods.
- `amlc test` command with class/method selection.
- Test-only dependency support and separate test build outputs.

### Changed
- Compiler flow separated production builds and test builds more clearly.

### Fixed
- Validation for invalid test declarations (including disallowed test parameters).

## [0.6.2] - 2025-09-26

### Added
- `switch` / `case` / `default` control-flow support.

### Changed
- Type-aware switch binding and validation integrated into the main pipeline.
- Generated C for switch logic aligned with runtime equality behavior.

### Fixed
- Structural and typing diagnostics for malformed switch statements.

## [0.6.1] - 2025-09-11

### Added
- String interpolation support.
- Array initializer syntax.
- Anonymous functions/lambda support.
- Enhanced loop constructs.
- Major generic-system improvements.
- Native integration framework and concurrency primitives.
- End-to-end build system improvements.

### Changed
- Core parser/binder/render pipeline matured significantly for modern language features.
