# Compiler usage (v0.13.0)

AmLang compiles `.aml` source to C, then invokes the configured target toolchain through make. The compiler is distributed as native executables and as a JAR requiring Java 21+.

## Invocation

```bash
amlc <command> <project-path> [options]
java -jar amlc-0.13.0.jar <command> <project-path> [options]
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

Run `clean` from the project directory: its current implementation addresses `builds/bin/<platform>/o` relative to the working directory. It does not remove generated C, test objects, or dependencies.

## Options

| Option | Purpose |
|---|---|
| `-bt <id>` | Select a configured build target |
| `-cores <n>` | Make parallelism (default 4) |
| `-fld` | Force dependency reloading |
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

Test builds retain the uniform calling convention and exception checks so mocks can throw. Tree-shaking is also enabled by `treeShake: true` on a selected target; to get a report-only run, leave that setting and `-ftree-shake` off.

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

| Output | Location |
|---|---|
| Production makefile | `builds/<platform>.makefile` |
| Production executable | `builds/bin/<platform>/app` |
| Production object files | `builds/bin/<platform>/o/` |
| Test makefile | `test-builds/<platform>.makefile` |
| Test executable | `test-builds/test-bin/<platform>/test_app` |

Tests no longer share the production generated-source tree. String constants use per-unit declarations; there is no shared `string_constants.h`.

## Toolchains and configuration

Platforms declare `ccCommand` (preferred) or `gccCommand`, assembler/linker commands, include paths, and native sources. Build targets select a platform and can override C compiler/assembler commands. `ccCommand` wins over `gccCommand` when both are supplied.

Use `gccRemoveOptions` and `linkerRemoveFlags` on a platform to subtract inherited flags. `dockerBuild` runs make in a container; its optional `platform` selects the container architecture. `sshBuild` uses SSH and rsync. `dockerTest` configures container execution of test binaries.

Root-package `compilerFlags: [singleThreaded]` selects the runtime's single-threaded ARC configuration. It must be consistent across all objects. Clean/rebuild when switching that setting or compiler commands; changes to target overrides do not automatically invalidate existing object files.

See the [README](../README.md#project-and-build-configuration) for configuration examples and the [release notes](../release-notes/RELEASE_NOTES_v0.13.0.md) for migration requirements.
