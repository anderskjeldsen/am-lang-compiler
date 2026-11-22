# Compiler usage (v0.16.0)

AmLang compiles `.aml` source to C, then invokes the configured target toolchain through make. The compiler is distributed as native executables and as a JAR requiring Java 21+.

## Invocation

```bash
amlc <command> <project-path> [options]
java -jar amlc-0.16.0.jar <command> <project-path> [options]
```

Only `--help` and `--version` work without a command and project path. Use `.` for the current project. Build target IDs must exist in that project's `package.yml`.

| Command | Example | Behavior |
|---|---|---|
| `new` | `amlc new my-project` | Prompt for project name and namespace; create a scaffold |
| `deps` | `amlc deps .` | Resolve dependencies without building |
| `build` | `amlc build . -bt linux-x64` | Generate C and build the selected target |
| `run` | `amlc run . -bt linux-x64` | Build and run the selected target |
| `test` | `amlc test . -bt linux-x64` | Compile and execute tests |
| `lint` | `amlc lint .` | Run the configurable source linter |
| `docs` | `amlc docs . -docformat both -docout api-docs` | Generate API documentation |
| `clean` | `amlc clean . -bt linux-x64` | Remove production object files for the target |

`clean` removes the object folders of the given build target, `builds/<targetId>/bin/o` and `test-builds/<targetId>/test-bin/o`, resolved against the package folder. Without `-bt` it asks before cleaning every declared target. It does not remove generated C or dependencies.

## Options

| Option | Purpose |
|---|---|
| `-bt <id>` | Select a configured build target |
| `-cores <n>` | Make parallelism (default 4) |
| `-fld` | Force dependency reloading |
| `-git-path <path>` | The `git` executable used to fetch git dependencies (default: `git` on `PATH`) |
| `-nowarn` | Print no warnings |
| `-wdeps` | Also list the dependencies' warnings (otherwise only counted) |
| `-lpp <directory>` | Prefer local packages at `<directory>/<package-id>/` |
| `-pof <file>` | Load YAML dependency overrides |
| `-tests "ClassName testMethod"` | Filter tests by class/method names |
| `-all` | Include dependency-package tests |
| `-ll <n>` | Compiler log level |
| `-to` | Enable allocated-object tracking |
| `-rl`, `-rlarc`, `-rdc` | Runtime, ARC, and generated-code diagnostics |
| `-reflection` | Reflect every class, as before v0.14.0; prefer per-class `#reflect` |
| `-ftree-shake` | Prune unreachable classes |
| `-ftree-shake-report` | Report prunable classes; does not enable pruning itself |
| `-fno-throws-opt` | Disable default throws/ABI optimization |
| `-fthrows-opt` | Accepted compatibility flag; optimization is already on by default |
| `-ftemplate-properties` | Accepted for compatibility; property-slot initialisation is decided per class since v0.14.0 |
| `-fseed-properties` | Seed slots in the constructor instead of clearing on allocation (opt-in; not recommended) |
| `-fescape-report` | Report `new` sites whose object cannot outlive its function; promotes nothing |
| `-docformat json`, `md`, or `both` | Select API documentation format |
| `-docout <directory>` | Select API documentation output directory |

Test builds retain the uniform calling convention and exception checks so mocks can throw, and they check integer division (see [Checked division](#checked-division)). Tree-shaking is also enabled by `treeShake: true` on a selected target; to get a report-only run, leave that setting and `-ftree-shake` off.

`-fborrow-slot-reads` was removed in v0.14.0: borrowed property-slot reads are unconditional now, and the flag is no longer read. Leaving it on a command line is harmless but does nothing.

### Allocation code generation (v0.14.0)

How a new object's property slots reach their starting state is decided per class variant, with no flag:

| the class's slots | what happens |
|---|---|
| all start as zero bytes (objects, `= null`) | the allocator's `memset` is the starting state; no image, no initializer call |
| start as compile-time constants (any primitive, `PRIMITIVE_NULL`, literal defaults) | a per-variant `const property` image, memcpy'd by the primary constructor, prepared allocator, no initializer call |
| have to be computed (string constant, `new`, a call, struct property, `init { }`, native base) | the instance initializer runs, as before |

Measured on am-git: binary 4,087,696 to 4,079,920 bytes (**−0.19%**, 19 variants needing an image), and an 18-slot allocation loop 217 ms to 207 ms. The binary gets smaller because an image is emitted only where it displaces work; the pre-v0.14.0 opt-in emitted 211 of them on the same program for +0.98%.

Not yet measured on m68k, where a memcpy is a libc call with no wide stores, and there is no slot-count threshold yet.

`-fseed-properties` is the alternative that did not pay: constructors seed every slot nothing else assigns, so the allocator need only clear the object header. It is kept with its measurements so the experiment is not repeated, and it carries a known hole — `ClassRef.newInstance`, the native exception throwers and cross-thread object copies allocate without running a constructor, so a property with no initializer is left as heap garbage.

`-fescape-report` is a report-only census of `new` sites whose object provably cannot outlive its function, as groundwork for promoting them into the isolate's arena automatically. See [Allocation scopes](14-allocation-scopes.md) for the arenas themselves.

## Output paths

Output is kept per build target, so two targets on the same platform never share object files.

| Output | Location |
|---|---|
| Production makefile | `builds/<targetId>/Makefile` |
| Production executable | `builds/<targetId>/bin/app` |
| Production object files | `builds/<targetId>/bin/o/` |
| Test makefile | `test-builds/<targetId>/Makefile` |
| Test executable | `test-builds/<targetId>/test-bin/test_app` |

`amlc build .` without `-bt` only parses, binds and validates. A package with no `buildTargets:` still renders a single `builds/` tree. The generated makefiles depend on a stamp of the compile flags, so changing a flag, the compiler command or a build target's options rebuilds every object. A build folder made by an older compiler has no stamp: clear its object folder once. String constants use per-unit declarations; there is no shared `string_constants.h`.

## Tests

`amlc test . -bt <target>` builds the package's tests into `test-builds/<targetId>/` and runs them from `test-builds/<targetId>/test-bin/`, so a test reads files relative to that folder. Before each run the test files are staged there, fresh:

| Package folder | Copied to |
|---|---|
| `tests/assets/` | `test-bin/assets/` |
| `test-assets/` | `test-bin/assets/` (laid over `tests/assets/` when both exist) |
| `tests/resources/` | `test-bin/resources/` |

A run in which no test ran fails with `Error: no tests were run` and exit status 1. Each test class is built as `new` would build it (constructor, property initializers, `init` blocks).

## Warnings

`build`, `run`, `test` and `lint` print the package's warnings after validation and before any C is generated, sorted by file and line, with a count:

```
Warning: /work/app/src/am-lang/App/Main.aml - Line 12: Call to obsolete function 'toInt' — Use as Int instead
1 warning in 1 file
65 more warnings in dependencies (-wdeps lists them, -nowarn hides all)
```

Warnings in dependencies are only counted, since the package being built can't fix them.

## Checked division

Integer `/`, `%`, `/=` and `%=` can check the divisor and throw `ArithmeticException` on a division by zero or a signed `minValue / -1` (see [Integer division by zero](02-syntax-grammar.md#integer-division-by-zero)). `amlc test` checks by default; `amlc build` and `amlc run` don't, and there the result of dividing by zero is unspecified. A build target overrides the default either way:

```yaml
buildTargets:
  - id: linux-x64-checked
    platform: linux-x64
    checkedDivision: true    # check in build and run too
  - id: linux-x64-fast-tests
    platform: linux-x64
    checkedDivision: false   # don't check even in amlc test
```

A checked build treats every AmLang function as one that may throw: `#noThrow` on a non-native function is ignored, and every non-native function keeps the `function_result` return ABI. Native functions keep their ABI. An unchecked build is as before: `#noThrow` is enforced and a division is not a throw site.

## Toolchains and configuration

Platforms declare `ccCommand` (preferred) or `gccCommand`, assembler/linker commands, include paths, and native sources. Build targets select a platform and can override C compiler/assembler commands. A target's `features:` list says which package features it enables; a target without the key enables none. `ccCommand` wins over `gccCommand` when both are supplied. A platform that names no compiler inherits its C compiler, assembler and linker commands from the platforms it extends, so a variant only needs `extends:`.

Use `gccRemoveOptions` and `linkerRemoveFlags` on a platform to subtract inherited flags. `dockerBuild` runs make in a container; its optional `platform` selects the container architecture. `sshBuild` uses SSH and rsync. `dockerTest` configures container execution of test binaries.

Root-package `compilerFlags: [singleThreaded]` selects the runtime's single-threaded ARC configuration. It must be consistent across all objects. Since v0.16.0 the makefile rebuilds every object when the compile flags or compiler commands change; a build folder made by an older compiler needs its object folder cleared once.

### Required stack

A build target can state how much stack its program needs:

```yaml
buildTargets:
  - id: amigaos_docker
    platform: amigaos
    requiredStack: 65536
```

Before anything else runs, the program compares this with its actual stack. If the stack is smaller, it prints the size needed and exits with status 20. On AmigaOS the user sets the stack with the Shell's `Stack` command or in the icon, and the program does not change it. The check does nothing on platforms outside the Amiga family. The compiler cannot work out the number, so measure it.

See the [README](../README.md#project-and-build-configuration) for configuration examples and the [release notes](../release-notes/RELEASE_NOTES_v0.16.0.md) for migration requirements.
