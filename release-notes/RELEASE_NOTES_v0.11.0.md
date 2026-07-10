# AmLang v0.11.0 Release Notes

**Release Date:** July 10, 2026

v0.11.0 is the largest release since the 0.6.x series. Two headline items — the nullability rework and thread-safe ARC — reshape how you write and how the runtime executes AmLang code. Everything else builds on those two.

## New Features

### 1. Draft Nullability Syntax

Bare object types are now **nullable by default**. A trailing `!` marks the type non-null. This aligns AmLang with the direction Kotlin and Swift took, and makes null a visible property of a type rather than an invisible one hiding behind every reference.

**Example:**
```amlang
class Person(var name: String!, var nickname: String) {
    // name is non-null; nickname is nullable (can be null)
}

class Greeter {
    static fun greet(p: Person!) {
        "Hello, ".println()
        p.name.println()             // OK — name is non-null
        if (p.nickname != null) {
            p.nickname.println()     // OK inside null-guard
        }
        // p.nickname.println()      // Compile error — needs !! or a guard
    }
}
```

**How assignment works:**
- Assigning a nullable to a non-null slot inserts an implicit non-null conversion (`!!assign`, `!!arg`) at bind time. At runtime, the guard checks the source and throws `Am.Lang.Exception` on NULL.
- Assigning non-null to a nullable slot is always fine.
- Field defaults for object types default to `null` when the field is nullable, and to a synthesised `!!` on the initializer otherwise.

**Migrating an existing package:**
- Add `legacyObjectNullability` to `package.yml`'s `compilerFlags` list. Bare object types stay non-null, matching pre-0.11.0 behavior.
- Add per-class `#legacyObjectNullability` to migrate the source file-by-file. Handy for `am-lang-core` and similar large modules.
- The `unit-testing` example, `am-lang-core`, `am-js`, `am-ui`, and every other in-tree package now sets one of these two flags so they build unchanged.

Primitive nullability is unchanged: `Int` is non-null, `Int?` opts in to the nullable-primitive representation (with an explicit `PRIMITIVE_NULL` flag bit).

### 2. Thread-Safe ARC (Cross-Thread Wrappers)

Reference counting is now safe across threads. Reads and writes of aobjects from a thread other than the allocating one route transparently through a **wrapper aobject** — a lightweight redirect whose `class_ptr == NULL` and whose real object hangs off `object_properties.object_wrapper.wrapped_object`.

Runtime characteristics:
- **`__unwrap` is near-free.** At `-O1+` it expands to one load + branch gated by a runtime `__amlc_any_wrappers_alive` flag, so a program that never mints wrappers pays essentially nothing. At `-O0` it's identity.
- **Wrappers respect propref.** `__decrease_reference_count` on a wrapper gates destruction on `rc == 0 ∧ propref == 0`, so a wrapper stored in a cross-thread `List` or `Array` no longer UAFs when the source local scope-exits.
- **Owner-refcount split.** Wrappers no longer mutate the real's `rc`. The real's owner thread runs a lock-free decrement; wrappers signal end-of-life through a shared `owner_gone` flag.

For AmLang source code the change is invisible — cross-thread field reads Just Work. For hand-written **native C** code the rule is:

> **Every raw aobject data-read in a hand-written native function must call `__unwrap(obj)` before dereferencing.**
> Refcount ops (`__increase_reference_count`, `__decrease_reference_count`) must NOT be unwrapped — refcount the raw wrapper you were handed.

The runtime's codegen already handles this everywhere it's responsible — native receivers, native args, `class_ptr` reads for `is`/`as`, array subscripts, iface-reference reads. The rule only bites in packages that carry hand-written native platform code (`am-ui`, `am-net`, `am-ssl`, ...). Those packages have been audited in-tree.

See the block comment at the top of `libc/core_inline_functions.h` for the full rule.

### 3. `OutOfMemoryException`

`new` allocation failure is now a catchable AmLang exception instead of a SIGSEGV.

**Example (inside a method body):**
```amlang
try {
    var huge = new UByte[hugeSize]
    // ... use huge ...
} catch (e: OutOfMemoryException) {
    "Ran out of memory — dropping cache and retrying".println()
    // release something and try again, or degrade gracefully
}
```

**How it works:**
- `Am.Lang.OutOfMemoryException` is a subclass of `Am.Lang.Exception` (so `catch (e: Exception)` also handles it).
- The runtime preallocates one instance at startup (`__init_oom_singleton`) so throwing OOM never itself needs to allocate.
- The `new` codegen emits a null-check after every `__allocate_object` / `__create_array` call. On NULL it throws the singleton through `__throw_out_of_memory_exception` and jumps to the enclosing `__exit_<block>` — same shape as any other runtime-thrown exception.

The singleton is re-used across throws, so its stack trace grows unbounded over the process's lifetime — bounded leak, acceptable for a process already in OOM territory. If startup itself can't allocate the singleton, the process aborts with a stderr message rather than silently crash later.

### 4. Interface Conversions

Multi-parent interfaces and iface-to-iface conversions now work as you'd expect.

**Transitive `iface_implementations`:**
```amlang
interface Callable {
    fun call()
}
interface Named {
    fun name(): String
}
interface CallableNamed : Callable, Named { }

class MyThing : CallableNamed {
    override fun call() {
        "called".println()
    }
    override fun name(): String {
        return "MyThing"
    }
}

class Demo {
    static fun main() {
        var c: Callable = new MyThing()   // OK — MyThing transitively implements Callable
        var n: Named    = new MyThing()   // OK — and transitively implements Named
    }
}
```

**Implicit iface-to-iface upcast:**
```amlang
interface Base { }
interface Sub : Base {
    fun subMethod()
}

class SubImpl : Sub {
    override fun subMethod() { }
}

class Demo {
    static fun takesBase(b: Base) {
        // ...
    }
    static fun main() {
        var s: Sub = new SubImpl()
        Demo.takesBase(s)                 // OK — Sub extends Base, implicit upcast
    }
}
```

Explicit `as` is still required for casts between unrelated interfaces (where the runtime shape check has to be deferred).

**`is SomeInterface`** now works. Previously it always returned `false` because the runtime helper (`is_descendant_of`) only walked `cls->base` and couldn't see interfaces. A new `implements_interface` runtime helper walks `cls->iface_implementations`; CRenderer picks the right helper based on whether the RHS is a class or an interface.

### 5. `buildTargets[].dockerTest`

Cross-compile a test binary in one container and run it in another. Landed with the workspace's `amiberry-headless/` image so an AmigaOS m68k test build can be verified end-to-end under Kickstart 3.1 + Amiberry's arm64 JIT — no local AmigaOS install needed.

**Example (`package.yml`):**
```yaml
buildTargets:
  - id: amigaos-amiberry
    platform: amigaos
    dockerBuild:
      image: amiga-gcc:latest
      buildPath: /host
    dockerTest:
      image: amlang-amiberry:latest
      timeoutSeconds: 900
```

**Usage:**
```
amlc test . -bt amigaos-amiberry
```

`amlc` cross-compiles the tests in `amiga-gcc:latest`, spawns `amlang-amiberry:latest`, mounts `test-bin/<platform>/` as `DH1:`, waits for the `=== TEST RUN COMPLETE ===` sentinel or the 900s timeout, prints the log, and exits.

The test runner codegen emits the sentinel after the Final Results block, so both a natural end-of-run and the fallback in the container's User-Startup script signal completion. The unit-testing example ships with this target — 250/250 tests pass under Amiberry.

Sibling to `dockerBuild` and the pre-existing `dockerRun`; the same image-allowlist gate applies.

### 6. `#onNativeTearDown` and Priority on Lifecycle Hooks

`#runOnExit`, `#runOnStartup`, and the new `#onNativeTearDown` directives now accept an optional integer priority:

```amlang
class Cleanup {
    #runOnExit(1000)
    static fun flushCaches() {
        // ... runs later
    }

    #runOnExit(-500)
    static fun snapshotMetrics() {
        // ... runs earlier
    }
}
```

Hooks emit into `startup.c` in ascending priority order — a higher number runs later, a negative number runs earlier. Ordering is global across all classes (not per-class); equal priorities preserve class-discovery order. Omit the parentheses to keep the default priority 0.

`#onNativeTearDown` is new: it registers a static **native** function to run at process exit, AFTER the GC sweep and per-class shutdown, when no AmLang objects remain. Intended for native-only teardown such as closing OS libraries opened lazily during the run. The compiler emits a direct C call to each hook — no AmLang forwarding, no exception handling, since the runtime is gone. The parser rejects it on non-static or non-native functions.

## Improvements

### `buildTargets[].sshBuild`

SSH+rsync analog of `dockerBuild`. Syncs the build tree to a remote host, runs `make` over ssh, rsyncs `bin/<platform>/` back. Useful for cross-compiling to architectures we don't run locally (real Linux boxes, ARM servers, an AmigaOS native host) without standing up Docker.

```yaml
buildTargets:
  - id: linux-x64-remote
    platform: linux-x64
    sshBuild:
      host: user@buildbox
      remoteBuildPath: /home/user/amlbuilds/myapp
```

### `special` Functions

New mechanism for the compiler to provide a function body directly at codegen time. Three-file recipe:
1. Declare `special static fun foo(): T` in the source.
2. Whitelist `Class.foo` in `FunctionValidator.knownSpecials`.
3. Implement in `CRenderer.renderSpecialFunctionFull`.

First user: **`Am.Lang.Runtime.getPlatform(): String`** returns the compile-time `AM_PLATFORM_ID` string (`"linux-x64"`, `"macos-arm"`, `"amigaos"`, ...). Backed by a new `-DAM_PLATFORM_ID="<platform.id>"` gcc flag emitted for both production and test makefiles.

```amlang
class Demo {
    static fun main() {
        Runtime.getPlatform().println()   // "linux-x64" / "amigaos" / ...
    }
}
```

### Polyvariant Class Split

Each type-argument variant of a generic class now lives in its own `.c` file: `List.c` + sibling `List__ta_Am_Lang_String.c`, etc. `make -j` scales across variants; a single edit to `List.aml` recompiles only the affected variant `.o` files instead of one giant `.c`.

### Skip Irrelevant Platform C Files

`CRenderer` no longer emits native forwarders for platforms other than the active build target. Cuts build-tree size significantly for packages with many platform stubs (`am-lang-core`, `am-ui`) and eliminates spurious "unused file" chatter.

### Package Overrides and Local Dependencies

Two new mechanisms for iterating on a package + a library side-by-side without pushing every change through the transitive-resolver:

- **`path: <relative>`** on a dependency entry resolves it from disk instead of the github cache.
- **`-lpp <root>`** CLI flag redirects github-realm transitive dependencies to `<root>/<id>/` — `am-lang-core`, `am-imaging`, `am-ui`, etc. — so an entire workspace can be built against in-tree edits without vendor-copy juggling.

### `-rlarc` ARC-Site Logging

Emits `[arc] site=class.fn:line` comments before every direct `__increase_reference_count` / `__decrease_reference_count` call, plus at ARC injection sites. Off by default; `-rlarc` turns it on for ARC audits.

### `array[i]` Bounds Check

Out-of-range subscripts throw `Am.Lang.Exception` with an "IndexOutOfBoundsException: index=N size=M" message. Compile-time-provable subscripts (literal indices into literal-init arrays) are exempt.

### Cross-Thread ARC Under the Hood

Beyond the wrapper mechanism itself, a handful of specific hazards landed as separate stages:
- **Array subscript unwrap** — `&arr[1]` codegen emits `&__unwrap(arr)[1]`; cross-thread `List<T>.get/set/iter` no longer silently return NULL through wrapper struct overlap.
- **Native primitive-descendant dispatch unwrap** — the receiver is `__unwrap`'d when boxed into `nullable_value` for a native callee. Cross-thread `String.hash()` no longer returns 0; `HashMap` lookups no longer falsely miss.
- **Iface `is`/`as` unwrap** — reads through `iface_reference.implementation_object` when the source is itself an interface.
- **Native ARC strip must spare bracket-pairs.** The ARC-strip sweep only removes `inc`/`dec` pairs that live in the same function. Cross-function bracket pairs (worker-entry `dec` matching the caller's `inc`) survive.

## Bug Fixes

### Suspend

- **`suspend throw-from-catch` + inline-suspend SEGV** — three-part fix; natural inline shapes work.
- **`suspend` exception lost in resume phase** — `throw` in the resume body was buried in local `__result` and never copied to `__state->result.exception`.
- **`suspend` state-index not zeroed** — child `suspend_state->index` recycled a stale value from the parent frame.
- **`suspend` loop-break gap** — `while` / `loop` with a suspend point inside now iterates correctly.
- **`suspend` from non-suspend must return void** — fire-and-forget is now the only supported shape.

### Try / Catch / Finally

- **`try { return X } finally` with `&&`** — codegen now saves and clears `__returning` across the finally block so the return-value expression side-effects don't leak.
- **`return` inside `catch` doesn't short-circuit** — code after the try/catch used to still run; the tail is now gated on a success flag.

### Parser and Binder

- **Chained subtraction is left-associative.** `a - b - c` now parses as `(a - b) - c` (was `a - (b - c)`). Same for `/`, `%`, `<<`, `>>`. `OperatorBinder` was fixed to match: arithmetic over non-primitive receivers (`String + String + ...`) no longer double-recurses, so left-associative chains bind in O(N) instead of the previous O(2^N) per leaf.
- **Not-operator argument precedence.** `!x.foo(y)` now parses as `!(x.foo(y))`, matching every mainstream language.
- **String literal `$`** — the string-template pre-scan no longer NPEs when the source contains a bare `$` that isn't followed by an interpolation identifier.
- **Nullable-primitive null-compare folded.** `nullablePrimitive` was ignored by the constant-folding guard so `x?.field == null` on a primitive type folded to `false` at compile time.
- **Number-constant issues** — literal parsing rejected leading `+`, and negative long literals sometimes bound as int-truncated.

### Codegen

- **`while (!method())`** no longer NPEs the renderer. The workaround (hoist to a `Bool` local) is no longer needed.
- **Base reference issue** — `super.method()` bound to the wrong class variant when the base was itself a generic type argument's class variant.
- **Don't null-check `this`.** Method bodies used to emit an `if (this == NULL)` guard at every property access on `this`. `this` is always non-null by construction; the check is dead code and now stripped.
- **Struct fixes** — assignment through boxed-struct property references now writes back to the box; nested-struct field access on an rvalue no longer NPEs.
- **Dual operator-renderer resolved.** Two independent branches of the operator codegen were merged into `CRenderer`'s single path, closing a long tail of "works with one flag, breaks with the other" reports.
- **`as SomeIface` codegen** — two fixes: the `.isInterface == true` compile-time gate was widened for downcast-to-iface, and the codegen now unwraps through `iface_reference.implementation_object` when the source is itself an interface (previous shape SIGSEGV'd at the first dispatch through the mis-allocated wrapper).

## Upgrade Notes

v0.11.0 is a significant release. The most likely upgrade friction is nullability. Read this section before bumping the dependency in a large project.

### Nullability migration

- **Every existing package should set `legacyObjectNullability` in `package.yml`'s `compilerFlags`** before upgrading. This preserves pre-0.11.0 behavior (bare object types are non-null) at the package level. Every package inside `am-lang-*`, `am-ui`, `am-net`, `am-js`, etc. already sets it.
- Migrate file-by-file with **`#legacyObjectNullability`** at the top of a class file, dropping it once you've audited the file and marked non-null slots with `!`.
- Only after every class file has migrated should you remove the package-level flag.
- Primitive nullability semantics are unchanged.

### Cross-thread ARC

- **AmLang source code needs no changes.** The runtime handles the wrapper mechanism transparently.
- **Hand-written native C code must call `__unwrap()`** before any data deref of an aobject that might have crossed threads. Refcount ops must not be unwrapped. See the block comment at the top of `libc/core_inline_functions.h` for the full rule. All in-tree native packages have been audited.
- If your package has `src/native-c/<platform>/` implementations of its own, run the audit script bundled in this release (`/tmp/check_unwrap.py` in a fresh working directory) and apply `/tmp/apply_unwrap.py` if you want the mechanical wrap.

### Directive changes

- `#runOnExit`, `#runOnStartup`, `#onNativeTearDown` accept an optional priority (`#runOnExit(1000)`). Existing hooks without a priority default to 0 and keep their previous placement.
- If you're relying on class-discovery order for multiple `#runOnExit` hooks that would previously have run in a specific order, add explicit priorities.

### `array[i]` bounds check

- Any code that was silently reading past the end of an array will now throw. Wrap the access in a length check or a `try`/`catch`.
- Literal-init arrays with literal-index reads are exempt at compile time (proven safe).

### `dockerTest` on AmigaOS packages

- To use `dockerTest`, build the `amiberry-headless/` image once (`./build.sh` from that folder) and drop your Kickstart 3.1 ROM in place first (`kick31.rom`).
- Existing `amigaos_docker` targets keep building the same way — `dockerTest` is opt-in per target.

## Known Follow-ups

Documented but not landed in 0.11.0:
- `is SomeClass` on an ARC wrapper still miscomputes (walks the wrapper's `class_ptr` which is NULL). Workaround: virtual dispatch instead of `is`-based shape checks over values that can cross threads.

### OOM plumbing extended in a v0.11.0 patch

The initial 0.11.0 tag covered the `new`-site OOM guard; follow-up patches (still tagged v0.11.0) extended the coverage to the internal runtime helpers:

- **`__create_string_constant` / `__create_string`** now return NULL on allocation failure instead of dereferencing a bogus `str_obj + 1`. Callers that have a `function_result *` in scope check the return and route through `__throw_out_of_memory_exception`.
- **`__create_exception`** returns the preallocated OOM singleton if it can't allocate a fresh `Exception`. `__decrease_reference_count` on the singleton is safe — its rc just churns.
- **`__throw_simple_exception`** falls back to `__throw_out_of_memory_exception` if either of its internal string-constant allocations fails, so a runtime-thrown Exception (bounds check, "size can't be negative", etc.) that can't build its message becomes a catchable OOM instead of a SIGSEGV.
- **`__wrap_if_foreign`** aborts with a clear stderr message if `__create_wrapper` returns NULL. Cross-thread wrap sites don't have a `function_result *` to route through, and returning the raw foreign pointer would silently corrupt subsequent reads, so a loud abort is strictly better.
- **`__create_array` size overflow check.** Before this patch, `size * item_size` did the multiply in `unsigned int * unsigned char` (item_size promotes to `unsigned int`) and could silently wrap at 2^32 on any host. `new Long[Int.max]` (16 GB request) then calloc'd only ~4 GB, quietly satisfying the allocation with a buffer far too small for the array's advertised size — every write past ~512M silently smashed unrelated heap allocations. Both operands are now promoted to `size_t` before the multiply, and the total is bounds-checked against `(size_t)-1 - sizeof(array_holder)`. Overflow returns NULL, which the codegen's post-`__create_array` guard turns into `OutOfMemoryException`. Also null-checks the allocation result — a valid but too-large request now throws OOM instead of dereferencing NULL.

The one remaining internal-runtime OOM path is `__allocate_object_data` (used by opaque data attachments on aobjects). That helper is currently unused in the runtime itself; it'll get null-check + exception routing whenever a caller lands.

## Full Changelog

See [`CHANGELOG.md`](CHANGELOG.md) for the complete list of changes. Historical changelogs live at `CHANGELOG_v<X.Y.Z>.md` per release.
