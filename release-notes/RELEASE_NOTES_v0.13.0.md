# AmLang v0.13.0 Release Notes

**Release Date:** September 25, 2026

v0.13.0 reduces generated code and incremental build work through shared generic implementations, a direct calling convention for non-throwing functions, packed exception metadata, and stable string constants. It also adds opt-in tree-shaking and fixes language, suspend, ARC, and cross-platform build issues.

**Upgrade attention:** this release removes legacy object nullability, changes generated C calling conventions, and moves test output to `test-builds/`. Review the migration steps below before upgrading.

## Smaller generated programs and faster rebuilds

- **Throws optimization is on by default.** Eligible non-throwing functions return their C result directly, and callers skip unnecessary exception checks. Use `-fno-throws-opt` to opt out. Test builds retain the uniform ABI and exception checks to support throwing mocks. `#noThrow` declares a checked contract for AmLang functions/operators and a trusted contract for native implementations. Interface and override chains follow their declaration's contract.
- **Generic methods share implementations** across compatible object-type variants. Each concrete variant retains its runtime identity, so allocation, reflection and type tests still distinguish types such as `List<String>` and `List<Date>`.
- **Packed exception-site metadata and static dispatch tables** reduce generated strings and startup code.
- **String constants have stable content-based names.** Each C unit declares only the constants it uses; editing one literal no longer invalidates every unit through a shared header. The first build with the new scheme regenerates the constant symbols.
- **ARC borrows eligible alias locals** without a retain/release pair. `-fborrow-slot-reads` enables an additional, narrowly scoped optimization for immediate primitive subscripting of array properties.

## Opt-in tree-shaking

Enable class-level pruning for a selected build target:

```yaml
buildTargets:
  - id: release
    platform: linux-x64
    treeShake: true
```

Alternatively, use `-ftree-shake`. Use `-ftree-shake-report` without either enabling setting to inspect the prunable classes without removing them.

The reachability walk starts from entry points, startup/exit hooks, explicitly retained classes and core runtime roots, then follows class references and inheritance. Use `#compileAlways` for a class reached only through native code or dynamic registration. Use `#compileAllImplementations` on an interface or base class to retain its implementations/subclasses too.

## Language improvements

- `??` now binds and renders null fallbacks for objects and nullable primitives, including `value?.method() ?? fallback`.
- Fully qualified class names and namespace-qualified static access resolve correctly; missing imports produce actionable diagnostics.
- Function types accept unnamed parameters, such as `(Int) => Bool`, and zero-argument lambdas work as call arguments.
- Object compound assignment, including string `+=`, updates the destination correctly.
- Nullable numeric casts convert their payload correctly, and non-null fields initialized in `init` blocks no longer need a duplicate inline initializer.

## Build configuration

- Use **`ccCommand`** for a toolchain-neutral C compiler command on a platform or build target. Existing `gccCommand` remains supported; `ccCommand` wins when both are set. Build targets also accept assembler overrides.
- Use **`gccRemoveOptions` / `linkerRemoveFlags`** to subtract inherited platform flags.
- Set **`dockerBuild.platform`**, for example `linux/amd64`, when a toolchain image requires a specific host architecture.
- Native C receives **`PLATFORM_<ID>` defines** for the target and its platform ancestors.
- Declare **`compilerFlags: [singleThreaded]` on the root package** to emit `AM_SINGLE_THREADED=1` consistently across production and test compilation. Use only for programs that never start threads and with a compatible runtime.
- Dependency clones are shallow, and native-source copying respects each dependency's platform inheritance. Test links now honor additional linker flags and flag removals.

## Reliability fixes

Suspend cleanup no longer releases uninitialized object locals on resumed exception paths. Root suspend completion coordinates state cleanup with the caller, and exception ownership is transferred without leaving a stale state pointer.

The release also fixes interface dispatch ABI mismatches, `Any`/nullable-value returns through the direct ABI, `either` ARC handling, generic `T[]` parameters rendering as `void`, strict-aliasing-sensitive array-holder access, and invalid exception metadata references from struct methods.

## Upgrade from v0.12.0

1. **Remove `legacyObjectNullability` everywhere.** Both the package flag and class directive are rejected, including flags in dependencies. Bare object types are non-null; spell nullable types explicitly with `?` and initialize non-null fields. For example:

   ```amlang
   var title: String = "Ready"
   var optionalTitle: String? = null
   var displayTitle: String = optionalTitle ?? "Untitled"
   ```

2. **Rebuild generated C and native objects together.** Use a compatible `am-lang-core` containing the packed exception-site and suspend rendezvous helpers. Generated ABI and string-constant symbols have changed. Native code that calls an AmLang function/operator's uniform `function_result` entry point by name should mark that declaration `#nativeEntry` so the compiler preserves it.

3. **Update test scripts.** Test makefiles now live at `test-builds/<platform>.makefile`; test executables live at `test-builds/test-bin/<platform>/test_app`. Production output remains under `builds/`. Remove assumptions about the generated `string_constants.h` header.

4. **Clean object output when switching toolchains or ABI options.** In particular, two build targets overriding the same platform's compiler command share its object directory; changing commands does not automatically invalidate those objects. Apply the same full-rebuild rule when changing `singleThreaded`.

5. **Review dynamically reached classes before enabling tree-shaking.** Add the keep directives where native code, reflection or registration supplies references the static walk cannot see.

## Known limitations

- Exception frames emitted from struct methods currently show `?` for the class name; the build failure is fixed, but struct class names are not represented in the packed site metadata.
- Generic sharing and tree-shaking are conservative. Not every specialization shares code, and tree-shaking removes whole classes rather than individual methods.
- The share-nothing thread model described in the design documents is future work, not part of this release.

## Full changelog

See [CHANGELOG_v0.13.0.md](CHANGELOG_v0.13.0.md) for the detailed changes since v0.12.0.
