# AmLang Compiler Changelog

All notable compiler changes are documented here.

## [0.11.0] - 2026-07-10

### Added

#### Nullability rework

- **Draft nullability syntax landed.** Bare `T` in a source position is now **nullable by default**; `T!` marks a type non-null. Assignment / return / parameter passing from a nullable to a non-null slot inserts an implicit non-null conversion (`!!assign`, `!!arg`) at bind time; the C codegen null-checks the source and throws `Am.Lang.Exception` on NULL. Field defaults for object types default to `null` when the field is nullable, and to a synthesised `!!` on the initializer otherwise. Primitives keep their old semantics (`Int` non-null; `Int?` nullable-primitive with an explicit `PRIMITIVE_NULL` flag bit).
- **`legacyObjectNullability` compiler flag** in `package.yml.compilerFlags` opts a package back into pre-0.11.0 behaviour: bare object types stay non-null, and every assignment / call that previously compiled continues to compile. Intended for the incremental migration path — set it on the root package and drop it once the source has been audited.
- Per-class `#legacyObjectNullability` directive: same effect as the package-level flag, scoped to one class file. Useful when migrating a large `am-lang-core` file at a time.
- `Type.toNonNullable()` helper for compiler internals; used by `OperatorBinder` and `FunctionCallBinder` to derive the non-null shape at implicit-conversion sites.
- `nullability-draft-test.aml` + `nullability-per-class-directive` fixtures document the accepted shapes.

#### Lifecycle hooks

- Lifecycle hook directives (`#runOnExit`, `#runOnStartup`, and the new `#onNativeTearDown`) now accept an optional integer priority: `#runOnExit(1000)`. Hooks are emitted into `startup.c` in ascending priority order, so a higher number runs later and a negative number runs earlier. Omitting the parentheses keeps priority 0. Ordering is global across all classes (not per-class); equal priorities preserve class-discovery order.
- `#onNativeTearDown` directive: registers a static **native** function to run at process exit, AFTER the GC sweep and per-class shutdown — i.e. once no AmLang objects remain. The compiler collects all `#onNativeTearDown` functions and emits a direct C call to each (straight to the native core symbol, no AmLang forwarding or exception handling, since the runtime is gone), referencing the prototype from the class's generated header which `startup.c` already includes. Intended for native-only teardown such as closing OS libraries opened lazily during the run. The parser rejects it on non-static or non-native functions.

#### Cross-thread ARC (thread-safe reference counting)

- **Wrapper aobject machinery.** When an object is accessed from a thread other than the one that allocated it, the runtime hands the reader a *wrapper* aobject — `class_ptr == NULL`, real object at `object_properties.object_wrapper.wrapped_object`. Reads through the wrapper transparently redirect via `__unwrap()` (an inline macro; identity on `-O0`, real ternary on `-O1+` gated by `__amlc_any_wrappers_alive` so single-thread programs pay ~one load + branch total). Stages 6–9 progressively closed cross-thread hazards: dispatch, property setters, wrapper lifetime, propref-regrowth-UAF and the ARM stale-read race.
- **`__unwrap` inserted at every codegen data-read site.** Native receiver / native args (`String.hash`, `HashMap.get`), `class_ptr` reads for `is`/`as`, array subscripts (`&arr[1]` → `&__unwrap(arr)[1]`), iface-reference reads. Hand-written native functions must call `__unwrap()` themselves — see the new note at the top of `libc/core_inline_functions.h`.
- **Wrapper aobjects respect propref.** `__decrease_reference_count` on a wrapper now gates destruction on `rc == 0 ∧ propref == 0` (not `rc == 0` alone), so a wrapper stored in a cross-thread `List`/`Array` no longer UAFs when the source local scope-exits.
- **Owner-refcount + `owner_gone` protocol.** Wrappers no longer mutate the real's `rc`. The real's owner thread runs a lock-free decrement; wrappers signal end-of-life via a shared `owner_gone` flag. `destruction_claimed` is now a lock-flag distinct from `pending_deallocation` (which stays the same-thread recursion guard).

#### OutOfMemoryException

- **`Am.Lang.OutOfMemoryException`** — subclass of `Am.Lang.Exception`, thrown by `new` codegen when the underlying `calloc` returns NULL. Before this change, allocation failure meant a SIGSEGV in the constructor call.
- **Preallocated singleton at startup.** The runtime allocates one `OutOfMemoryException` at process start (`__init_oom_singleton` in `libc/core.c`, called from `main` and `test_main` right after `clear_allocated_objects`) so the throw path itself never has to allocate. If startup can't allocate the singleton, the process aborts loudly with a stderr message rather than silently crash later.
- **`new` codegen emits a null-check.** After every `__allocate_object` / `__allocate_object_with_extra_size` / `__create_array` call — including the mock and struct-autobox paths — the generated C now reads:
  ```c
  <var> = __allocate_object(&Foo);
  if (<var> == NULL) {
      __throw_out_of_memory_exception(&__result, "at Class.fn on line N (allocation failed)");
      __returning = true; goto __exit_<block>;
  }
  Foo_f_Foo_0(<var>);
  ```
- `Am.Lang.Exception.aml` grows the class + an aggressive comment about the "singleton is re-used across throws so its stack trace grows unbounded — acceptable for a process already in OOM territory" tradeoff.
- **Runtime-helper OOM plumbing.** Follow-up patch to the initial `new`-site guard: `__create_string_constant` / `__create_string` propagate NULL on allocation failure; `__create_exception` falls back to the OOM singleton if it can't allocate a fresh Exception; `__throw_simple_exception` routes to `__throw_out_of_memory_exception` if either of its internal string-constant allocations fails (so bounds checks / negative-array-size throws become catchable OOM instead of SIGSEGV); `__wrap_if_foreign` aborts with a stderr message if `__create_wrapper` returns NULL. Closes most of the "runtime helpers still crash on internal OOM" gap flagged in the initial release notes.
- **`__create_array` size-overflow guard.** `size * item_size` used to wrap `unsigned int * unsigned char` modulo 2^32, so `new Long[Int.max]` silently satisfied a 16 GB request with a ~4 GB buffer; writes past ~512M then smashed unrelated heap allocations. Both operands are now promoted to `size_t` before the multiply, and the total (including the `array_holder` header) is bounds-checked against `(size_t)-1`. Overflow returns NULL, which the codegen's post-`__create_array` guard turns into `OutOfMemoryException`. Also null-checks the allocation result. Closes the last of the three known follow-up items from the initial 0.11.0 release notes.

#### Interface conversions

- **`class C : SubIface` transitively implements `SuperIface`.** `ClassVariant.buildInterfaceImplementations` now recurses through iface-inheritance chains, so the runtime `class_ptr->iface_implementations` list contains every ancestor iface. Drops the old "declare every super-iface explicitly on the class" workaround.
- **Implicit iface-to-iface conversion.** `var s: SuperIface = subIface` compiles when `SubIface` transitively extends `SuperIface`. Explicit `as` still required for unrelated interfaces.
- **Return-position iface upcast.** `bindReturnStatement` now runs the same `injectAsOperator` the assignment / parameter-passing paths use. Without this a `return subIface` from a function typed `: SuperIface` would propagate the sub's iface wrapper unchanged and the caller's slot-0 method dispatch would land on the wrong function.
- **Multi-parent interfaces** (`interface Multi : A, B { }`) with **inherited** functions now resolve at call sites. `allFunctionsWithOverrides` on interfaces walks super-iface chains (with a cycle-guard for diamond inheritance); `findRealClassVariantForFunction` mirrors the walk. Enables shapes like `interface JsHostCallableObject : JsHostObject, JsHostCallable { }` — no need to re-declare `call` on the sub.
- **`is SomeIface` runtime check** — new `implements_interface` runtime helper that walks `cls->iface_implementations` (the pre-fix code called `is_descendant_of`, which only walked `cls->base` and missed every interface). CRenderer picks the right helper based on whether the RHS is a class or an interface.
- **`as SomeIface` codegen** — two fixes: the `.isInterface == true` compile-time gate was widened for downcast-to-iface, and the codegen now unwraps through `iface_reference.implementation_object` when the source is itself an interface (previous shape SIGSEGV'd at the first dispatch through the mis-allocated wrapper).

#### Build targets

- **`buildTargets[].sshBuild`** — SSH+rsync analog of `dockerBuild`. Syncs the build tree to a remote host, runs `make` over ssh, rsyncs `bin/<platform>/` back. Same precedence as `dockerBuild` (a target with both blocks set: docker wins).
  ```yaml
  buildTargets:
    - id: linux-x64-remote
      platform: linux-x64
      sshBuild:
        host: user@buildbox
        remoteBuildPath: /home/user/amlbuilds/myapp
  ```
- **`buildTargets[].dockerTest`** — cross-compile with `dockerBuild`, then execute the test binary inside a container. Landed with the workspace's `amiberry-headless/` image so an `amigaos` test build can be verified end-to-end under Kickstart 3.1 + Amiberry's arm64 JIT without an AmigaOS install on the developer host.
  ```yaml
  buildTargets:
    - id: amigaos-amiberry
      platform: amigaos
      dockerBuild: { image: amiga-gcc:latest, buildPath: /host }
      dockerTest: { image: amlang-amiberry:latest, timeoutSeconds: 900 }
  ```
- **`amlc test` build path routes through `dockerBuild`** (in addition to `amlc build`). Previously the test-mode build was hardcoded to local `make`, so a cross-compile-only target had no way to build the test binary. Same image-allowlist gate as `amlc build`.
- **`=== TEST RUN COMPLETE ===` sentinel** emitted after the test runner's Final Results block. The amiberry-headless container's `entrypoint.sh` polls for this exact string to distinguish "ran to end" from "hung mid-suite" and time out accordingly.

#### Compiler internals & tooling

- **`special` functions** — new mechanism for the compiler to provide a function body directly at codegen time (instead of walking a user-authored AmLang body). Three-file recipe: declare `special fun foo(): T` in the source, whitelist `Class.foo` in `FunctionValidator.knownSpecials`, implement in `CRenderer.renderSpecialFunctionFull`. First user: `Am.Lang.Runtime.getPlatform(): String` returns the compile-time `AM_PLATFORM_ID` string.
- **`Am.Lang.Runtime.getPlatform()`** — static `special` function returning `"linux-x64"` / `"macos-arm"` / `"amigaos"` etc. Backed by the new `-DAM_PLATFORM_ID="<platform.id>"` gcc flag emitted by `MakefileRenderer` for both production and test makefiles.
- **Polyvariant class split** — each type-argument variant of a generic class now lives in its own `.c` file (`List.c` + sibling `List__ta_Am_Lang_String.c`, etc.). `make -j` scales across variants; a single edit to `List.aml` recompiles only the affected variant `.o` files instead of one giant `.c`.
- **Irrelevant-platform C files no longer rendered.** Previously, `CRenderer` emitted native forwarders for every platform in `package.yml` regardless of the active build target. Now only the target platform's files land in `builds/shared/native/`, cutting build-tree size and eliminating spurious "unused file" chatter.
- **Package overrides + local dependencies.** New `path: <relative>` on a dependency entry resolves it from disk instead of the github cache — useful for developing an app + a library side-by-side without pushing every change through the transitive-resolver. Alongside, the `-lpp <root>` CLI flag redirects github-realm transitive dependencies to `<root>/<id>/` (`am-lang-core`, `am-imaging`, ...), so a whole workspace can be built against in-tree edits without vendor-copy juggling.
- **`-rlarc` flag** — arc-site logging. Emits `[arc] site=class.fn:line` comments before every direct `__increase_reference_count` / `__decrease_reference_count` call, plus at ARC injection sites. Off by default; -rlarc turns it on for ARC audits.
- **AmLang `array[i]` bounds check.** Out-of-range subscripts throw `Am.Lang.Exception` with a "IndexOutOfBoundsException: index=N size=M" message. Literal-init subscripts are compile-time proven and exempt.

### Changed

- **`renderRunOnExitCalls` / `renderRunOnStartupCalls`** collect hooks across all classes and emit them in a single priority-sorted pass instead of per-class iteration order. `#runOnExit` placement is unchanged (after `main()` returns, before the GC sweep, so hooks still see live AmLang state).
- **Chained subtraction is left-associative.** `a - b - c` now parses as `(a - b) - c` (was `a - (b - c)`). Same for `/`, `%`, `<<`, `>>`. The `Row.aml` `Short/toShort` workaround is no longer needed. `OperatorBinder` was fixed to match: arithmetic over non-primitive receivers (`String + String + ...`) no longer double-recurses, so left-associative chains bind in O(N) instead of the previous O(2^N) per leaf.
- **Native ARC strip must spare bracket-pairs.** The ARC-strip sweep now only removes `inc`/`dec` pairs that live in the same function. Bracket pairs across function boundaries (e.g. the worker-entry `__decrease_reference_count` matching the caller's `__increase_reference_count`) survive.
- **Test build makefile respects `dockerBuild`.** See "Build targets" above.

### Fixed

- **`try { return X } finally` with `&&`** — codegen now saves and clears `__returning` across the finally block so the return-value expression side-effects don't leak. Fixes the shape where a `finally` short-circuit would drop the `return`.
- **`return` inside `catch` doesn't short-circuit** — code after the try/catch used to still run. The tail is now gated on a success flag.
- **`suspend throw-from-catch` + inline-suspend SEGV** — three-part fix; natural inline shapes work.
- **`suspend` exception lost in resume phase** — `throw` in the resume body was buried in local `__result` and never copied to `__state->result.exception`. Parent saw a default-NULL return and silently coerced throws to NULL returns.
- **`suspend` state-index not zeroed** — child `suspend_state->index` recycled a stale value from the parent frame.
- **`suspend` loop-break gap** — `while` / `loop` with a suspend point inside now iterates correctly (previously broke on the second iteration).
- **`suspend` from non-suspend must return void** — the codegen would emit a value-returning path that the caller couldn't consume; fire-and-forget is now the only supported shape.
- **Nullable-primitive null-compare folded.** `nullablePrimitive` was ignored by the constant-folding guard so `x?.field == null` on a primitive type folded to `false` at compile time.
- **`while (!method())`** no longer NPEs the renderer. Previously a bare `!obj.method()` as a while-condition tripped a codegen path that assumed the negation was on an object reference. Workaround was to hoist to a `Bool` local — no longer needed.
- **Not-operator argument precedence.** `!` bound too loosely against a following argument list. `!x.foo(y)` now parses as `!(x.foo(y))`, matching every mainstream language.
- **`is` / `as` interface unwrap** — reads through `iface_reference.implementation_object` when the source is itself an interface, so `wrapper as Iface` no longer produces a wrapper-of-a-wrapper.
- **Array subscript unwrap.** `&arr[1]` codegen now emits `&__unwrap(arr)[1]`; cross-thread `List<T>.get/set/iter` no longer silently return NULL through wrapper struct overlap.
- **Native primitive-descendant dispatch unwrap.** The receiver is `__unwrap`'d when boxed into `nullable_value` for a native callee (e.g. `String.hash`). Cross-thread `String.hash()` no longer returns 0; `HashMap` lookups no longer falsely miss.
- **Base reference issue** — `super.method()` bound to the wrong class variant when the base was itself a generic type argument's class variant.
- **Don't null-check `this`.** Method bodies used to emit an `if (this == NULL)` guard at every property access on `this`. `this` is always non-null by construction; the check is dead code and now stripped.
- **Number-constant issues** — literal parsing rejected leading `+`, and negative long literals sometimes bound as int-truncated.
- **Struct fixes** — assignment through boxed-struct property references now writes back to the box; nested-struct field access on an rvalue no longer NPEs.
- **String literal `$`** — the string-template pre-scan no longer NPEs when the source contains a bare `$` that isn't followed by an interpolation identifier (dotted/`__` prefixes work as sentinels).
- **Dual operator-renderer resolved.** Two independent branches of the operator codegen were merged into `CRenderer`'s single path, closing a long tail of "works with one flag, breaks with the other" reports.

## [0.10.0] - 2026-04-29

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
- Writing to boxed struct members (e.g. `obj.structProp.x = value`) now persists correctly.
- Compound assignment operators (`+=`, `-=`, `|=`, `&=`) on fields of a boxed struct property (e.g. `this.position.x += dx`) now correctly write back to the box, so the change is visible to subsequent reads.
- Multiple edge cases in struct boxing/unboxing code generation were stabilized.
- `new ClassName()` expressions now produce a non-null type, so variables inferred from `new` no longer get redundant null-checks before every method call, reducing generated code size.
- Variables annotated with `!` (e.g. `var x: Foo!`) no longer receive a null-check guard before each member access.
- Non-null conversion (`!!`, `!!assign`, `!!arg`) on enum values backed by a primitive type (e.g. `enum Foo<UByte>`) no longer emits an invalid `== NULL` comparison, which previously caused a C compiler warning.

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
