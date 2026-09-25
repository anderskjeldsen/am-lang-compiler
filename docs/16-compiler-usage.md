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
| `--reflection` | Generate ClassRef/PropertyInfo registration metadata |
| `-ftree-shake` | Prune unreachable classes |
| `-ftree-shake-report` | Report prunable classes; does not enable pruning itself |
| `-fno-throws-opt` | Disable default throws/ABI optimization |
| `-fthrows-opt` | Accepted compatibility flag; optimization is already on by default |
| `-fborrow-slot-reads` | Enable narrowly proven borrowed array-property reads |
| `-docformat json`, `md`, or `both` | Select API documentation format |
| `-docout <directory>` | Select API documentation output directory |

Test builds retain the uniform calling convention and exception checks so mocks can throw. Tree-shaking is also enabled by `treeShake: true` on a selected target; to get a report-only run, leave that setting and `-ftree-shake` off.

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
