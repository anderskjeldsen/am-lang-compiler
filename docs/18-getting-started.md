# Getting started with AmLang v0.13.0

## Install

Follow the [installation instructions](../README.md#installation). Native compiler executables need no Java; the JAR requires Java 21+. Application builds also require make, a C toolchain, and the target's native libraries.

```bash
amlc --version
amlc new my-project
cd my-project
```

Answer the project-name and root-namespace prompts. The generated package has a Linux x64 build target and dependencies on `am-lang-core` and the test-only `am-tests` package.

## Write a program

Replace the generated `src/am-lang/<namespace>/Program.aml` with:

```amlang
namespace HelloWorld {
    class Program {
        import Am.Lang

        static fun main() {
            var name: String? = null
            var greeting: String = name ?? "World"
            "Hello, $greeting!".println()
        }
    }
}
```

Use `.aml` files, put imports inside classes, and declare the entry point `static`. Keep a single application entry point. Bare object types are non-null; use `?` for nullable values.

## Build and run

On Linux x64:

```bash
amlc build . -bt linux-x64
amlc run . -bt linux-x64
```

For another host or cross-compilation target, add its platform and build target to `package.yml` first. See the [Linux/macOS configuration example](../README.md#project-and-build-configuration). The target ID after `-bt` must match your package; the compiler does not supply a universal `native` target.

The executable is written to `builds/bin/<platform>/app`.

## Add a test

Create `tests/GreetingTest.aml`:

```amlang
namespace HelloWorld.Tests {
    class GreetingTest {
        import Am.Lang

        test testFallback() {
            var name: String? = null
            var actual: String = name ?? "World"
            if (actual != "World") {
                throw new Exception("Expected fallback greeting")
            }
        }
    }
}
```

```bash
amlc test . -bt linux-x64
amlc test . -bt linux-x64 -tests GreetingTest
```

Test output lives in `test-builds/`, separate from production builds. See the [mock examples](../examples/unit-testing/) for scoped method replacement.

## Continue

- [Current language features](../README.md#language-features)
- [Compiler commands and output paths](16-compiler-usage.md)
- [v0.13.0 migration steps](../README.md#upgrading-to-v0130)
- [Documentation index](README.md)
