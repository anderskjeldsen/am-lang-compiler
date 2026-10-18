# AmLang Compiler

AmLang is a statically typed, object-oriented language that compiles to C and then to a native executable using your target's C toolchain. It combines classes, generics, structs, automatic reference counting, suspend functions, and built-in tests with native C integration.

[![GitHub Release](https://img.shields.io/github/v/release/anderskjeldsen/am-lang-compiler)](https://github.com/anderskjeldsen/am-lang-compiler/releases)

This repository contains public documentation, examples, installation tools, and compiler releases. This README describes **v0.14.0**. Start with the [release notes](release-notes/RELEASE_NOTES_v0.14.0.md) and [upgrade steps](#upgrading-to-v0140) if you already use AmLang.

## What's new in v0.14.0

- **Share-nothing isolate threads:** each thread owns its static properties, and `Thread.send`/`receive` deep-copy messages between isolates. Native classes opt in with `#sendable`.
- **`shared static` properties:** one copy for the whole process when you genuinely want threads to see the same value. Primitives only, stored as their own C type, and unsynchronised by design.
- **Allocation scopes:** `scratch { ... }` bump-allocates from the isolate's arena, including in callees; `keep { ... }` forces the normal heap for objects that outlive the block; `#keepAlways` covers classes that escape by construction. `fast { ... }` remains as the legacy spelling.
- **Reflection by `#reflect` closure:** an annotated class carries a read-only descriptor, built into `ClassRef`/`PropertyInfo` lazily, so startup costs nothing. The old `-reflection` flag now means "reflect everything".
- **`main` may return `Int`**, and the value becomes the process exit status. A throwing `main` exits 1.
- **Faster property reads:** call-free slot reads skip the retain/release pair unconditionally — measured at 30% on the HashSet insert path — superseding `-fborrow-slot-reads`.
- **Property slots initialise per class:** a class whose slots all start as null costs a `memset` and nothing else, one whose starting state is constant gets a per-variant image memcpy'd in, and only one that has to compute its state keeps the instance-initializer call. On am-git that is 0.19% *less* binary and a 5% faster allocation loop; it replaces the opt-in `-ftemplate-properties`.

See the [full changelog](CHANGELOG.md) for the fixes to property stamping, name-versus-method binding, generics inference and test startup.

**This release requires the matching `am-lang-core`.** The generated code addresses per-isolate statics, the immortal object flag and new `aclass` fields, none of which exist in an older core.

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
| Linux x64 | `amlc-linux-x64-0.14.0.tar.gz` | `amlc-linux` |
| macOS ARM64 | `amlc-macos-arm64-0.14.0.tar.gz` | `amlc-mac-arm64` |
| Windows x64 | `amlc-windows-x64-0.14.0.zip` | `amlc-windows.exe` |
| Any supported Java 21+ host | `amlc-jar-0.14.0.tar.gz` or `.zip` | `amlc.sh`, `amlc.bat`, or `java -jar amlc-0.14.0.jar` |

For example, on Linux x64:

```bash
curl -fLO https://github.com/anderskjeldsen/am-lang-compiler/releases/download/v0.14.0/amlc-linux-x64-0.14.0.tar.gz
tar -xzf amlc-linux-x64-0.14.0.tar.gz
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

Production output goes to `builds/`, with the executable at `builds/bin/<platform>/app`. Tests use a separate `test-builds/` tree.

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

Threading and suspend support come from the compiler and `am-lang-core` runtime. **v0.14.0 moves to share-nothing isolate threads:** static properties live per isolate, `Thread.send`/`receive` deep-copy their messages, and each isolate carries the bump arena that [allocation scopes](docs/14-allocation-scopes.md) draw from. Use `shared static` for state that must be one copy across threads, and `#reflect` for [reflection](docs/13-reflection.md); `-reflection` still reflects everything.

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

Mocks are scoped; nested `scope` blocks support temporary overrides. See the [unit-testing example](examples/unit-testing/) for calculator sources and additional mock scenarios. Test executables are written to `test-builds/test-bin/<platform>/test_app`, with makefiles at `test-builds/<platform>.makefile`.

## Platforms

The **compiler host** and the **generated program's target** are separate choices. A compiler running on macOS can generate code for AmigaOS when the target toolchain and native libraries are available.

| Target family | Platform IDs in the current core configuration |
|---|---|
| Linux | `linux-x64`, `linux-arm64v8`, `linux-ppc32`, `linux-ppc64` |
| macOS | `macos` (Intel), `macos-arm` (Apple Silicon) |
| AmigaOS 3.x | `amigaos` (m68k) |
| MorphOS | `morphos-ppc` |
| AROS | `aros-x86-64`, `aros-arm64`, `aros-m68k` |

Target availability depends on your package configuration, C toolchain, and native dependencies. A Windows-hosted compiler is distributed, but the new Windows x64 **core runtime target** remains separate development work and is not included in this v0.14.0 core branch. Generated executables may require platform libraries; native compilation does not imply a fully static executable.

## Performance

The [benchmark example](examples/performance_test/ReadMe.md) compares array and non-array point-processing workloads across several languages. Its recorded timings are historical measurements for that workload and machine, not a v0.14.0 benchmark or a general performance ranking.

v0.14.0 focuses on allocation cost — arenas, property-slot seeding and borrowed slot reads — on top of v0.13.0's work on generated-code size, exception-call overhead and incremental rebuilds. Measure your application with its intended C compiler, optimization flags, and target hardware.

## Upgrading to v0.14.0

1. **Upgrade `am-lang-core` to the matching release.** Not optional: the generated code addresses per-isolate statics, the immortal object flag and new `aclass` fields, none of which exist in an older core. A mismatched pair fails at the C compile.
2. **Audit statics that were shared between threads.** A plain `static` is now one copy *per isolate*, so two threads writing it no longer see each other's value — silently. Move genuinely shared primitive state to `shared static`, guard it yourself, or pass it in a message.
3. **Audit what you send between threads.** `Thread.send`/`receive` deep-copy, and a native class that has not opted in with `#sendable` is refused at runtime.
4. **Replace `-reflection` with `#reflect` where you can.** The flag still works and now reflects every class; the directive reflects one class and its closure, which is what keeps startup free.
5. **Drop `-fborrow-slot-reads` from build scripts.** Borrowed property-slot reads are unconditional now and the flag is no longer read.
6. **Check `main`'s return type.** An `Int` return is now the process exit status, and a throwing `main` exits 1 instead of 0.

Upgrading from v0.12.0 or earlier? Work through the [v0.13.0 upgrade steps](release-notes/RELEASE_NOTES_v0.13.0.md) first — legacy object nullability is rejected, test output moved to `test-builds/`, and the borrowed-parameter convention from v0.12.0 applies to native functions that retain object arguments. See the [v0.14.0 release notes](release-notes/RELEASE_NOTES_v0.14.0.md) for details and known limitations.

## Documentation and examples

- [Documentation index](docs/README.md), [getting started](docs/18-getting-started.md), and [compiler usage](docs/16-compiler-usage.md)
- [Hello world](examples/hello-world/), [loop syntax](examples/loop-keyword-demo/), [file browser](examples/file-browser/), and [unit tests](examples/unit-testing/)
- [v0.14.0 release notes](release-notes/RELEASE_NOTES_v0.14.0.md), [v0.13.0 release notes](release-notes/RELEASE_NOTES_v0.13.0.md), and [release history](CHANGELOG.md)

Libraries include [am-lang-core](https://github.com/anderskjeldsen/am-lang-core), [am-json](https://github.com/anderskjeldsen/am-json), [am-net](https://github.com/anderskjeldsen/am-net), [am-ssl](https://github.com/anderskjeldsen/am-ssl), [am-ui](https://github.com/anderskjeldsen/am-ui), and [am-imaging](https://github.com/anderskjeldsen/am-imaging). Check each library's platform support and compiler compatibility when adding it to a project.
