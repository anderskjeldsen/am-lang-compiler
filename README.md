# AmLang Compiler

AmLang is a statically typed, object-oriented language that compiles to C and then to a native executable using your target's C toolchain. It combines classes, generics, structs, automatic reference counting, suspend functions, and built-in tests with native C integration.

[![GitHub Release](https://img.shields.io/github/v/release/anderskjeldsen/am-lang-compiler)](https://github.com/anderskjeldsen/am-lang-compiler/releases)

This repository contains public documentation, examples, installation tools, and compiler releases. This README describes **v0.16.0**. Start with the [release notes](release-notes/RELEASE_NOTES_v0.16.0.md) and [upgrade steps](#upgrading-to-v0160) if you already use AmLang.

## What's new in v0.16.0

v0.16.0 is mostly about correctness: more than a hundred fixes, many of them code that compiled without a word and did the wrong thing.

- **Array literals hold any expression, and nest:** `[a, f(x), Color.red]`, `[[1, 2], [3, 4]]`, `[new Circle(1), new Rect(2, 3)]`.
- **Labeled loops:** `break@outer` and `continue@outer` leave or continue an outer loop, releasing objects and running `finally` on the way.
- **Nullable enums:** `Color?` is null, not the member whose value is 0.
- **`when` over an enum needs no `else`** when every member has a branch; a missing member is a compile error that names it.
- **Lambdas:** typed parameters (`(x: Int) => x * 2`), one parameter without parentheses (`n => n > 1`), expression bodies, and an inferred type for a lambda in an untyped local.
- **Integer division is checked in tests:** under `amlc test` a division by zero throws `ArithmeticException` with file and line. Release builds don't check; `checkedDivision` on a build target chooses either way.
- **`String.compareTo`**, path style conversion in `Am.IO.File`, `TaskScheduler.runAsync`, and a warning for a signed and an unsigned integer in one operator.
- **Breaking:** out of memory shuts the program down instead of throwing; `<` and `>` on strings, hex literal suffixes and `"a" + i` are compile errors; type arguments must match; build output is per build target in `builds/<targetId>/`.

See the [release notes](release-notes/RELEASE_NOTES_v0.16.0.md) for the breaking changes in full, and the [changelog](CHANGELOG.md) for every fix.

**Upgrade `am-lang-core` to 0.16.0 at the same time.**

## Installation

### Automatic installation

On a system with Bash and curl:

```bash
curl -fsSL https://raw.githubusercontent.com/anderskjeldsen/am-lang-compiler/master/scripts/install-amlc.sh | bash
amlc --version
```

The installer chooses a native compiler when available and otherwise uses the JAR distribution. To select the JAR explicitly:

```bash
curl -fsSL https://raw.githubusercontent.com/anderskjeldsen/am-lang-compiler/master/scripts/install-amlc.sh | bash -s -- --type jar
```

The JAR requires **Java 21 or newer**. Native compiler executables do not require Java. Building an AmLang application still requires **make, a C compiler, and the headers/libraries for its target**.

### Manual downloads

Download from [GitHub Releases](https://github.com/anderskjeldsen/am-lang-compiler/releases). The release workflow builds these distributions; the assets attached to a release show which builds completed:

| Compiler host | Archive | Launcher/executable |
|---|---|---|
| Linux x64 | `amlc-linux-x64-0.16.0.tar.gz` | `amlc-linux` |
| macOS ARM64 | `amlc-macos-arm64-0.16.0.tar.gz` | `amlc-mac-arm64` |
| Windows x64 | `amlc-windows-x64-0.16.0.zip` | `amlc-windows.exe` |
| Any supported Java 21+ host | `amlc-jar-0.16.0.tar.gz` or `.zip` | `amlc.sh`, `amlc.bat`, or `java -jar amlc-0.16.0.jar` |

For example, on Linux x64:

```bash
curl -fLO https://github.com/anderskjeldsen/am-lang-compiler/releases/download/v0.16.0/amlc-linux-x64-0.16.0.tar.gz
tar -xzf amlc-linux-x64-0.16.0.tar.gz
chmod +x amlc-linux
./amlc-linux --version
```

Rename/install the executable as `amlc` on your `PATH` to use the commands below. On hosts without a native asset, including macOS Intel and Linux ARM64, use the JAR.

## Getting started

Create a project and answer the project-name and root-namespace prompts:

```bash
amlc new my-project
cd my-project
```

The scaffold contains `package.yml`, a Makefile, and a `.aml` program under `src/am-lang/<namespace>/Program.aml`. Replace the generated program with this example, keeping one entry point:

```amlang
namespace HelloWorld {
    class Program {
        import Am.Lang

        static fun main() {
            "Hello, AmLang!".println()
        }
    }
}
```

The scaffold defines a Linux x64 target. On Linux with GCC and make installed:

```bash
amlc build . -bt linux-x64
amlc run . -bt linux-x64
```

Both commands require a project path (`.` here). `-bt` selects an ID from that project's `buildTargets`; it is not a globally predefined target. Add a matching platform and build target for other systems, as in the configuration below.

Production output goes to `builds/<targetId>/`, with the executable at `builds/<targetId>/bin/app`. Tests use a separate `test-builds/<targetId>/` tree.

## Language features

| Area | Features |
|---|---|
| Types | Signed/unsigned integers, floating-point types, strings, nullable objects and primitives, generics, enums, and structs |
| Objects | Classes, single class inheritance, interfaces with multiple parents, virtual methods, constructors, and `init` blocks |
| Functions | Lambdas, function types, extension functions, inline functions, and suspend functions |
| Expressions | Type inference, string interpolation, safe calls `?.`, null fallback `??`, casts `as`, and type tests `is` |
| Control flow | Conditions, loops including `each`, switch statements, exceptions, and `try`/`catch`/`finally` |
| Memory | Automatic reference counting, borrowed parameters, allocation-failure exceptions, and optional object/ARC diagnostics |
| Integration | Native classes/functions, inline C, platform-specific native implementations, and feature-controlled declarations |
| Tooling | Unit tests, scoped mocks, linting, API documentation, and configurable local/container/remote builds |

Imports belong inside the class body. The following complete program demonstrates generics, lambdas, and null handling:

```amlang
namespace Examples {
    class Program {
        import Am.Lang
        import Am.Collections

        static fun main() {
            var names = new List<String>()
            names.add("Ada")
            names.add("Linus")
            each(name in names) {
                "Hello, $name".println()
            }

            var title: String? = null
            var displayTitle: String = title ?? "Untitled"
            displayTitle.println()

            var isPositive: (Int) => Bool = (value) => {
                return value > 0
            }
            isPositive(3).toString().println()
        }
    }
}
```

Bare types such as `String` are non-null. Use `String?` or `Int?` when a value may be null. Nullable-to-non-null conversions can insert runtime checks; use `?.` and `??` to handle null explicitly.

Struct equality compares fields recursively. Struct copy/reference behavior depends on the operation; do not assume every assignment and argument has the same semantics as an object reference.

Threading and suspend support come from the compiler and `am-lang-core` runtime. **Since v0.14.0, threads share nothing:** static properties live per isolate, `Thread.send`/`receive` deep-copy their messages, and each isolate carries the bump arena that [allocation scopes](docs/14-allocation-scopes.md) draw from. Use `shared static` for state that must be one copy across threads, and `#reflect` for [reflection](docs/13-reflection.md); `-reflection` still reflects everything.

### Directives and runtime information

- `#obsolete` marks deprecated functions and can include a replacement hint.
- `#runOnStartup` and `#runOnExit` register lifecycle hooks with optional integer priorities; `#onNativeTearDown` runs native cleanup after runtime teardown.
- `#implementationPlatforms` selects the platform-specific native implementations for a native class.
- `Am.Lang.Runtime.getPlatform()` reports the build platform, and `Runtime.getPackages()` uses compiler-generated `Am.Lang.BuildInfo` to report non-test package versions.
- `instances(SomeClass)` reads live-instance counts when object tracking is enabled, including in test builds.

## Project and build configuration

A minimal project with Linux and Apple Silicon targets:

```yaml
id: my-app
version: 1.0.0
type: application
dependencies:
  - id: am-lang-core
    realm: github
    type: git-repo
    tag: latest
    url: https://github.com/anderskjeldsen/am-lang-core.git
platforms:
  - id: libc
    abstract: true
  - id: linux-x64
    extends: libc
    ccCommand: gcc -O2
  - id: macos-arm
    extends: libc
    ccCommand: clang -O2
buildTargets:
  - id: linux-x64
    platform: linux-x64
  - id: macos-arm
    platform: macos-arm
```

For Apple Silicon, run `amlc build . -bt macos-arm`. Use a compatible `am-lang-core` revision; for reproducible builds, replace `latest` with an existing tag or revision supported by your dependency setup.

Dependencies can also use `type: local` with `path: ../my-library` for local development. `-lpp /path/to/packages` checks `<directory>/<package-id>/` before the declared dependency location. `-pof overrides.yml` supplies dependency overrides.

### Build options

- **Compiler commands:** `ccCommand` takes precedence over the compatible older spelling `gccCommand`. Build targets can override C compiler and assembler commands. `gccAdditionalOptions` and `additionalLinkerFlags` add flags; platform `gccRemoveOptions` and `linkerRemoveFlags` remove inherited flags.
- **Feature selection:** packages declare features, dependencies/build targets select them, and `#require` controls declarations. A feature declared `global: true` can be referenced with the `!` prefix. Enable the core's `floatingPoint` feature when using its floating-point facilities.
- **Tree-shaking:** add `treeShake: true` to a selected build target or pass `-ftree-shake`. To inspect candidates without pruning, use `-ftree-shake-report` with tree-shaking otherwise disabled. `#compileAlways` retains a class; `#compileAllImplementations` also retains subclasses and interface implementations.
- **Throws optimization:** enabled by default for eligible production code; use `-fno-throws-opt` to disable it. Test builds keep exception checks and the uniform calling convention so mocks can throw.
- **Slot borrowing:** `-fborrow-slot-reads` is opt-in in this release. It removes retains/releases for narrowly proven immediate primitive-array accesses through `this`.
- **Single-threaded runtime:** root-package `compilerFlags: [singleThreaded]` emits `AM_SINGLE_THREADED=1`. Use it only for programs that do not start threads, and rebuild all objects when changing it.

Native C receives `PLATFORM_<ID>` defines for the selected platform and its ancestors. Clean object output when changing compiler commands or ABI-affecting settings; switching targets that override the same platform does not automatically invalidate those objects.

### Docker and SSH builds

A target can use a container for C compilation:

```yaml
buildTargets:
  - id: amigaos-docker
    platform: amigaos
    dockerBuild:
      image: amiga-gcc:latest
      buildPath: /work
```

This requires an `amigaos` platform declaration, compatible native dependencies, and the toolchain image. See the included [Amiga GCC Docker files](docker/amiga-gcc/). Set `dockerBuild.platform`, for example `linux/amd64`, when the image requires a particular container architecture.

`sshBuild` supports SSH/rsync builds on a remote host. `dockerTest` can run cross-compiled tests in a container; AmigaOS emulation also needs an appropriately configured emulator image and ROM. These tools must be configured separately from installing the compiler.

## Commands

Run these from a project containing the referenced build target:

```bash
amlc --help
amlc --version
amlc new my-project
amlc deps .
amlc build . -bt linux-x64
amlc run . -bt linux-x64
amlc test . -bt linux-x64
amlc test . -bt linux-x64 -tests "CalculatorTest testAddition"
amlc lint .
amlc docs . -docformat both -docout api-docs
amlc clean . -bt linux-x64
```

`clean` removes production object files for the selected target; it is not a full cleanup of generated C and test output. See [compiler usage](docs/16-compiler-usage.md) for options and paths.

## Unit tests and mocks

Put test classes in `tests/` and add `am-tests` as a dependency with `testOnly: true`. Tests use the `test` keyword, and a thrown exception marks a failure. For example, with a `Calculator.add` method in namespace `Example`:

```amlang
namespace ExampleTests {
    class CalculatorTest {
        import Am.Lang
        import Example

        test testAddition() {
            var calculator = new Calculator()
            if (calculator.add(5, 3) != 8) {
                throw new Exception("Expected 8")
            }
        }

        test testMock() {
            mock Calculator {
                fun add(a: Int, b: Int): Int {
                    return 100
                }
            }
            var calculator = new Calculator()
            if (calculator.add(5, 3) != 100) {
                throw new Exception("Expected mocked result")
            }
        }
    }
}
```

Mocks are scoped; nested `scope` blocks support temporary overrides. See the [unit-testing example](examples/unit-testing/) for calculator sources and additional mock scenarios. Test executables are written to `test-builds/<targetId>/test-bin/test_app`, with the makefile at `test-builds/<targetId>/Makefile`.

## Platforms

The **compiler host** and the **generated program's target** are separate choices. A compiler running on macOS can generate code for AmigaOS when the target toolchain and native libraries are available.

| Target family | Platform IDs in the current core configuration |
|---|---|
| Linux | `linux-x64`, `linux-arm64v8`, `linux-ppc32`, `linux-ppc64` |
| macOS | `macos` (Intel), `macos-arm` (Apple Silicon) |
| AmigaOS 3.x | `amigaos` (m68k) |
| MorphOS | `morphos-ppc` |
| AROS | `aros-x86-64`, `aros-arm64`, `aros-m68k` |

Target availability depends on your package configuration, C toolchain, and native dependencies. A Windows-hosted compiler is distributed, and am-lang-core (since 0.15.0) has a `windows-x64` runtime target, built with the MinGW cross-compiler. Generated executables may require platform libraries; native compilation does not imply a fully static executable.

## Performance

The [benchmark example](examples/performance_test/ReadMe.md) compares array and non-array point-processing workloads across several languages. Its recorded timings are historical measurements for that workload and machine, not a v0.16.0 benchmark or a general performance ranking.

v0.14.0 focused on allocation cost — arenas, property-slot seeding and borrowed slot reads — on top of v0.13.0's work on generated-code size, exception-call overhead and incremental rebuilds. Measure your application with its intended C compiler, optimization flags, and target hardware.

## Upgrading to v0.16.0

1. **Upgrade `am-lang-core` to 0.16.0.**
2. **Fix the new compile errors:** drop hex literal suffixes (use `as` where nothing gives the type), replace `<`/`>` on strings with `compareTo`, add `.toString()` or a template where a non-String is added to a String, put a `try`/`catch` in a `toString`, `hash` or `equals` override that can throw, and convert arrays and generics whose type arguments differ.
3. **Remove `catch` blocks for `OutOfMemoryException`;** out of memory now shuts the program down.
4. **Update scripts that read build output:** `builds/<targetId>/bin/app` instead of `builds/bin/<platform>/app`, and `test-builds/<targetId>/`.
5. **Check code that relied on old behaviour:** a `Long + Int` that was cut to an Int, `?.x == null` that was false, a null `Bool?` that counted as false, and Byte arithmetic on ARM or PowerPC.
6. **Make sure `git` is on `PATH`** for git dependencies, and run your tests: `amlc test` now checks integer division.

Upgrading from v0.14.0 or earlier? Work through the [v0.15.0 upgrade steps](release-notes/RELEASE_NOTES_v0.15.0.md) first — `to` in a `for` loop now includes its end, and `amlc` exits 1 on failure. From v0.13.0 or earlier, the [v0.14.0 upgrade steps](release-notes/RELEASE_NOTES_v0.14.0.md) first; from v0.12.0 or earlier, the [v0.13.0 upgrade steps](release-notes/RELEASE_NOTES_v0.13.0.md) before that — legacy object nullability is rejected, test output moved to `test-builds/`, and the borrowed-parameter convention from v0.12.0 applies to native functions that retain object arguments. See the [v0.16.0 release notes](release-notes/RELEASE_NOTES_v0.16.0.md) for details and known limitations.

## Documentation and examples

- [Documentation index](docs/README.md), [getting started](docs/18-getting-started.md), and [compiler usage](docs/16-compiler-usage.md)
- [Hello world](examples/hello-world/), [loop syntax](examples/loop-keyword-demo/), [file browser](examples/file-browser/), and [unit tests](examples/unit-testing/)
- [v0.16.0 release notes](release-notes/RELEASE_NOTES_v0.16.0.md), [v0.15.0 release notes](release-notes/RELEASE_NOTES_v0.15.0.md), [v0.14.0 release notes](release-notes/RELEASE_NOTES_v0.14.0.md), [v0.13.0 release notes](release-notes/RELEASE_NOTES_v0.13.0.md), and [release history](CHANGELOG.md)

Libraries include [am-lang-core](https://github.com/anderskjeldsen/am-lang-core), [am-json](https://github.com/anderskjeldsen/am-json), [am-net](https://github.com/anderskjeldsen/am-net), [am-ssl](https://github.com/anderskjeldsen/am-ssl), [am-ui](https://github.com/anderskjeldsen/am-ui), and [am-imaging](https://github.com/anderskjeldsen/am-imaging). Check each library's platform support and compiler compatibility when adding it to a project.
