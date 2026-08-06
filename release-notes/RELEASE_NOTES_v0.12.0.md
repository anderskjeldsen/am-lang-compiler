# AmLang v0.12.0 Release Notes

**Release Date:** August 6, 2026

Where v0.11.0 reshaped the language surface, v0.12.0 is about what the compiler *emits*. The headline is a calling-convention change that removes two refcount operations per object argument on every call, plus a batch of ARC correctness fixes — one of which was a latent use-after-free. There is also a new `#obsolete` directive, hex literals that behave like C, and a self-describing `Am.Lang.BuildInfo` class.

## Performance

### Borrowed parameter convention

Object parameters and `this` are no longer retained by the callee.

Every call site already materialises its arguments as owned temporaries that live until the caller's enclosing block ends — strictly longer than the call itself. The callee-side retain/release bracket was therefore pure overhead: two refcount operations per object argument per call, and under thread-safe ARC, two global-lock round trips per call for a cross-thread receiver.

Ownership-taking positions stay explicit and unchanged:

- returns are `+1` via `__retain_function_return`
- property stores retain through propref
- `suspend` functions keep their entry retains, because a suspended frame outlives the caller's owned temporaries

**If you write native code:** a native function that stashes an object pointer beyond the call must now retain it explicitly. In-tree natives have been audited (see the `DO-NOT-STRIP` worker reference in `Thread.c`).

## New Features

### `#obsolete` directive

Mark a function as deprecated and get a compile-time warning at every call site.

```amlang
class Legacy {
    #obsolete
    static fun oldWay() { }

    #obsolete 'use readAll() instead'
    static fun readEverything(): String { return "" }
}
```

Calling `readEverything()` warns:

```
Warning: Function 'readEverything' is obsolete: use readAll() instead
```

The optional message is free-form text in single quotes and is appended to the warning. Warnings are de-duplicated — the binder runs once per function variant, so the same call site would otherwise report several times. Extension functions are covered as well as instance and static functions.

### `Am.Lang.BuildInfo`

The compiler now synthesises an `Am.Lang.BuildInfo` class listing every non-test package compiled into the binary, so `Am.Lang.Runtime.getPackages()` can report `id -> version` at runtime.

It is generated as ordinary AmLang source and fed through the normal parser pipeline, so it binds, validates and renders exactly like hand-written code. Test-only dependencies (`am-tests` and friends) are filtered out — a loaded package counts as test-only when nothing but `testOnly` declarations pull it in. The root package is never test-only.

### `instances` intrinsic

`instances` is now a reserved keyword. `instances(SomeClass)` reads the live instance count maintained by the runtime under `-DTRACKOBJECTS`, which test builds enable automatically.

## Language Changes

### Hex literals are signed bit patterns

A hex literal whose top bit is set now folds to a negative number of the target type, matching C:

```amlang
var x: Int = 0x80000000      // -2147483648, was an error
var m: Byte = 0x80B          // -128
var s: Short = 0xFFFFS       // -1
```

Folding is width-aware and honours the type suffix (`B`, `S`, `I`, `L`); a literal too wide for its type is still an error rather than being silently truncated.

### Methods on constants

Calling a method directly on a literal now works:

```amlang
var s = 42.toString()
```

Note that identity conversions were deliberately **not** added — `someInt.toInt()` is still an error. `as Int` remains the preferred spelling, and it is faster.

## Bug Fixes

### ARC and memory

- **Parameter reassignment leaked, and could use-after-free.** Assigning to a parameter promotes its slot from a caller-owned borrow to an owning local — the assignment codegen releases the old value and retains the new one. Without a matching entry retain and exit release, the function both leaked the assigned value *and* over-released the caller's reference. The latter is a use-after-free that had not yet been observed in the wild. Now detected at bind time (including `+=`) and bracketed correctly. Locals were never affected.
- **Loop-head temporaries leaked one wrapper per iteration.** Expressions in a `while` condition re-execute with the temporary's cleanup bound to the enclosing block, so the owned handle from the previous iteration was overwritten and lost. Property reads now pre-release before re-assigning. This was the chunk-streaming leak.
- **`inline fun` returning from inside a loop leaked every temporary** inc'd in the enclosing blocks. Inline results now unwind through the normal `__returning` / `goto __exit_<block>` cascade so each enclosing block runs its cleanup, instead of jumping straight to the inline exit label.
- **Exceptions thrown inside an inlined body** are now re-raised into the caller's block cascade, taking the same unwind a `throw` at the call site would, so enclosing `try`/`catch` blocks catch them and every caller block's cleanup runs.

### Codegen

- **`var x: T` with no initializer was dropped entirely.** Primitive locals are now zero-seed-declared, so seeding a variable before first use is no longer required.
- **`n = null` on a nullable primitive local** (`Int?`) was rejected by the operator validator, which ignored the `nullablePrimitive` flag.
- **The wrong `main` could be selected.** When a root application depends on another `type: application` package (for example `am-git`), both expose `main` and the last one in iteration order won — silently running the wrong program. The root package's `main` now wins.

### Diagnostics

- **Unresolved method calls report the real problem.** `0xD2800000.toInt()` used to produce `Can't inject as operator on expression without evaluating expression '0xD2800000'`, pointing at the receiver. It now reports `Function 'toInt' not found on type 'Am.Lang.Int'`.
- Warnings are de-duplicated, and `ErrorLogger` exposes a read-only view of accumulated warnings for tests.

## Testing

The suite grows to **129 tests**, with new scenario coverage for `#obsolete`, hex-literal folding, methods on constants, and parameter-reassignment ARC.

## Upgrading

No source changes are required for ordinary AmLang code. Two things to check:

1. **Native code** that retains an object argument beyond the lifetime of the call must now do so explicitly — see *Borrowed parameter convention* above.
2. **Hex literals with the top bit set** previously failed to compile; if you worked around that with an explicit negative constant, the literal spelling now works and means the same thing.
