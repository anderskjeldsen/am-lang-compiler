# AmLang Compiler v0.13.0 Changelog

## [0.13.0] - 2026-09-25

Changes since v0.12.0.

### Added

- **Null-coalescing operator `??`.** Bind and render object and nullable-primitive fallbacks, including fallbacks following a safe-call chain (`value?.method() ?? fallback`).
- **`#noThrow` contracts on functions and operators.** Verify AmLang bodies and implementations of annotated abstract/interface declarations; trust annotated native implementations. Suspend functions cannot declare `#noThrow`.
- **`#nativeEntry` on functions and operators.** Preserve the uniform `function_result` entry point when hand-written native code calls a generated function by name.
- **Opt-in class-level tree-shaking.** Enable with `-ftree-shake` or `treeShake: true` on the selected build target. `-ftree-shake-report` reports prunable classes without enabling pruning by itself. `#compileAlways` retains a class; `#compileAllImplementations` also retains its subclasses and interface implementations.
- **Root-package `compilerFlags: [singleThreaded]`.** Emit `AM_SINGLE_THREADED=1` in production and test compilation for the runtime's single-threaded ARC mode.
- **Qualified class paths.** Resolve fully qualified types such as `Am.Lang.String` and namespace-qualified static access. Missing-import diagnostics now suggest the namespace instead of letting an unresolved `new` expression crash the renderer.
- **Unnamed function-type parameters.** Accept `(Int) => Bool` and nested function types alongside named-parameter syntax.
- **Build configuration:** `ccCommand` on platforms and build targets, target-level `gccCommand`/`asmCommand` overrides, `dockerBuild.platform`, and platform `gccRemoveOptions`/`linkerRemoveFlags`. `ccCommand` takes precedence over `gccCommand`.
- **Platform C defines.** Emit `PLATFORM_<ID>` defines for the target and its ancestor platforms in production and test builds.
- **Amiga emulator tooling.** Add `amiberry-docker/make-fpu-sys.sh` to prepare a SYS drive for hard-float testing using libraries from a user-supplied Workbench image.

### Changed

- **Breaking: remove legacy object nullability.** Reject both the `legacyObjectNullability` package flag and `#legacyObjectNullability` directive. Bare object types are non-null; use `?` for nullable objects. Remove the flag from dependencies as well as the root package.
- **Breaking for build scripts: separate test output.** Generate tests under `test-builds/`, with `<platform>.makefile` and `test-bin/<platform>/test_app`, instead of mixing them into `builds/` with `<platform>.test.makefile`.
- **Throws optimization is enabled by default.** Eligible non-throwing functions return their real C type directly, and eligible callers omit exception checks. `-fno-throws-opt` restores the uniform ABI/checking path; `-fthrows-opt` remains accepted. Test builds retain the uniform ABI and exception checks so mocks can throw. Unannotated overridable/interface chains remain potentially throwing regardless of their current implementations.
- **Share generic method implementations.** Compatible object-type variants share C method bodies through per-variant entry points and type dictionaries, while retaining concrete runtime class identities for allocation, reflection, and `is`/`as`. Primitive/struct/enum specialization is retained; function-level generics, suspend functions and native functions keep per-variant code where required.
- **Static virtual dispatch tables** replace runtime table construction where applicable.
- **Packed exception-site metadata** replaces per-site pooled stack-trace strings, including null, cast, bounds, size and allocation checks.
- **Stable string-constant symbols.** Name constants by a hash of their UTF-8 contents and emit per-unit extern declarations instead of a shared `string_constants.h`. Definitions remain in `startup.c`; hash collisions fail with a diagnostic. Suspend temporary declarations also use a stable order, reducing unnecessary incremental recompilation.
- **ARC borrow elision.** Avoid retain/release pairs for eligible alias locals sourced from `this`, stable parameters or constants. The opt-in `-fborrow-slot-reads` additionally borrows eligible array-property reads used immediately for primitive subscripting with call-free indices/values and a `this` receiver.
- **Shallow dependency clones.** Upgrade JGit to 6.10 and clone dependencies with depth 1.

### Fixed

- Object compound assignment such as `text += suffix` now performs the assignment instead of silently doing nothing.
- Zero-argument lambdas now bind correctly as call arguments.
- Numeric casts involving nullable primitives convert the numeric payload instead of incorrectly taking the runtime class-cast path.
- `either` expressions returning `Any` or nullable primitives use the appropriate `nullable_value` ARC helper.
- Suspend object locals are initialized before resume dispatch, avoiding cleanup of uninitialized stack pointers on exception paths. Root suspend completion coordinates state ownership with the caller, and resumed exceptions are cleared from the state once transferred.
- Generic `T[]` parameters inside generic bodies render as object pointers and follow ARC instead of degrading to `void`.
- Interface implementations share throws analysis and ABI decisions with their interface declarations, preventing mismatched dispatch-table entries.
- Direct non-throwing ABI returns preserve the complete `Any`/nullable-value representation; calls within shared generic bodies select the matching implementation ABI.
- Generated array-holder access uses byte-offset pointer arithmetic to avoid strict-aliasing miscompilation.
- Throwing struct methods no longer reference a nonexistent class symbol in exception metadata. Such stack frames currently display `?` for the class name.
- Non-null properties assigned in an `init` block no longer require a duplicate inline initializer to satisfy validation.
- Documentation comments survive intervening whitespace before their declaration.
- Dependency native sources follow each dependency's own platform inheritance chain. Root-defined platform stubs also allow dependencies to reach their existing ancestor implementations.
- Test link commands honor `additionalLinkerFlags` and `linkerRemoveFlags`.
- Unreadable sources such as dangling C-library symlinks are skipped with a warning instead of aborting the copy step.

### Upgrade notes

- Audit nullable object declarations and remove legacy-nullability flags/directives throughout the dependency graph.
- Rebuild generated C and native objects together with a compatible `am-lang-core`: generated calls now use packed exception-site helpers, suspend rendezvous support, and the updated calling conventions. Add `#nativeEntry` to AmLang functions/operators whose uniform entry points are called by native code.
- Update scripts that refer to test build paths or the old shared string-constants header.
- Clean object output when changing compiler commands or ABI-affecting options. Switching build targets that override the same platform's toolchain does not automatically invalidate existing objects.
- Before enabling tree-shaking, mark classes reached only by native code, dynamic registration or reflection with the appropriate keep directives. Pruning is at class granularity and remains opt-in.
- Use `singleThreaded` only for programs that do not start threads, and rebuild all objects when changing this setting.
