# AmLang v0.16.0 Release Notes

**Release Date:** Unreleased

v0.16.0 is mostly about correctness. More than a hundred fixes, many of them code that compiled without a word and did the wrong thing: wrong values, leaks, crashes in generated code and crashes in the compiler. It also adds array literals that hold any expression, labeled `break` and `continue`, nullable enums, a `when` over an enum that needs no `else`, typed lambda parameters and short lambda forms, and checked integer division in tests. Out of memory is now fatal, and build output is kept per build target.

**Upgrade attention:** several changes turn code that used to compile into a compile error, and a few change what a program does. Upgrade `am-lang-core` to 0.16.0 at the same time; see [Upgrading](#upgrading-to-v0160).

## Array literals hold any expression, and nest

```aml
var a = 5
var xs = [a, 2, f(3)]
var grid: Int[][] = [[1, 2], [3, 4]]
var shapes = [new Circle(1), new Rect(2, 3)]   // Shape[]
```

Elements can be locals, parameters, calls, enum values, `new` objects, strings and `null`. They are evaluated once each, left to right. The element type is the declared type when there is one: a variable, a parameter, a return type or a property. Otherwise it is the elements' common type: integers widen, `Float` with `Double` is `Double`, and objects widen to a shared base class or interface. `[]` needs a declared type.

## Labeled loops: `break@name` and `continue@name`

```aml
outer@ for (i = 0 until n) {
    for (j = 0 until m) {
        if (grid[i * m + j] == target) { break@outer }
        if (skip(j)) { continue@outer }
    }
}
```

This works on `for`, `while`, `loop` and both `each` forms, and in suspend functions. A labeled jump leaves the blocks between it and its loop like `return` does: each block releases its objects and every `finally` runs. An unknown label, a label on something that isn't a loop and a jump out of a lambda are compile errors. `outer` stays usable as a name.

## Nullable enums

```aml
var k: Color? = null
var c = k ?? Color.white
```

`Color?` is null, not the member whose value is 0. `!= null`, `!!`, `??` and `?.` work on it, as do `Color?` properties, parameters, returns, `List<Color?>` and `new Color?[n]`. A generic `T?` slot holding an enum, such as `HashMap<K, Color>.getOrNull` on a missing key, is null instead of reading 0. An enum in an `Any` now keeps its type, so `a is Color` and `a as Color` work.

## `when` over an enum needs no `else`

```aml
fun name(c: Color): String = when (c) {
    Color.red -> "red"
    Color.green, Color.blue -> "cool"
}
```

A `when` used as a value over an enum compiles without `else` when every member has a branch. Leaving one out is an error that lists the missing members. So adding a member to an enum later finds every `when` that must handle it, where an `else` would have hidden it. A `Color?` subject also needs a `null` branch. The subject of a value `when` can now be any expression, evaluated once.

## Lambdas: typed parameters, short forms, inferred types

```aml
var f = (x: Int) => x * 2
var g = () => show(4)
list.filter(n => n > 1)
twice(() => counter.add())
```

- **Typed parameters:** a lambda parameter may declare its type. With no function type to take it from, the declared types and what the body returns are the lambda's type.
- **Expression bodies:** an expression body returns its value when the function type has a return type. For a `() => void` type it runs as a statement.
- **One parameter:** a single parameter needs no parentheses.
- **No parameters:** a lambda with no parameters in an untyped local takes its type from its body.

## Integer division by zero is checked in tests

```aml
try { var share = total / count } catch (e: ArithmeticException) { e.message.println() }
```

Under `amlc test`, integer `/`, `%`, `/=` and `%=` check the divisor. A zero divisor throws `ArithmeticException("Division by zero")` with the class and line. A signed `minValue / -1` throws `"Division overflow"`. In a test build `#noThrow` is ignored on every function that isn't native, so the exception can come from anywhere.

`amlc build` and `amlc run` don't check. A division by zero there has an unspecified result, which depends on the processor:

| Processor | Result |
|---|---|
| x86 | The program crashes with SIGFPE. |
| 68k AmigaOS | A Guru Meditation. |
| ARM64 | The quotient is 0. |
| PowerPC | Garbage. |

A build target can set `checkedDivision: true` or `false` in `package.yml` to choose either way. A literal divisor other than 0 is never checked, and `Float`/`Double` division is unchanged.

## Smaller additions

- **`String.compareTo(other)`** orders strings byte by byte on their UTF-8 form, which is code point order.
- **A warning when a signed and an unsigned integer meet in one operator.** `-1 == 4294967295UI` is true in C, and now the compiler says so.
- **Path style conversion in `Am.IO.File`.** `File.fromUnixPath("./data/../assets")` gives the host's form of a path written once in source, and `toUnixPath` goes back. Amiga and Windows styles work the same way, and `File.convertPath` converts between any two.
- **`TaskScheduler.runAsync<T>(threadType, work)`** runs `work` on a worker thread and resumes the suspend function with its result.
- **Warnings appear on every build, test and lint,** not only when the build fails. `-wdeps` lists the dependencies' warnings too, and `-nowarn` hides them all.

## Breaking changes

- **Out of memory shuts the program down instead of throwing `OutOfMemoryException`.** It used to count as a throw site at every `new`, which made nearly every function "can throw". Now the thread that runs out prints `Out of memory allocating <class>`, every thread stops, the objects the skipped frames held are released (so open files close), and the program exits with status 20. On AmigaOS and MorphOS a thread that doesn't stop within 10 s is removed.
- **`<`, `>`, `<=` and `>=` on two strings are an error.** They compared the strings' addresses. Use `a.compareTo(b) < 0`. `==` is unchanged.
- **Hex literals take no type suffix, and `B` in a hex literal is a digit.** `0x1B` was silently the Byte 1; it is now 27. Write `0xFF` where the type is given, or `(0x80000000 as UInt)` where it isn't.
- **Build output is per build target,** in `builds/<targetId>/` with `bin/app` and objects in `bin/o`, and tests in `test-builds/<targetId>/`. Two targets on the same platform no longer share object files. `amlc build .` without `-bt` only checks the package. The generated makefile now rebuilds every object when the compile flags change.
- **An override of a `#noThrow` function whose body can throw is an error.** This applies to `toString()`, `hash()` and `equals()`. The message names the throw site. Catch with `try { … } catch (e: Exception) { … }` inside the override.
- **Type arguments must match.** An `Int[]` doesn't pass as a `Long[]`, nor a `List<Dog>` as a `List<Animal>`. Before, the callee read the ints as longs.
- **A mixed-width integer operation has the wider operand's type.** `before + 1` with `before: Long` is a Long in either order. Before, `Long + Int` took the right operand's type and was cut to 32 bits.
- **`"a" + i` with a non-String operand is a compile error.** Before, it crashed the compiler, gave a wrong string or segfaulted. Write `"a" + i.toString()` or a template: `"a${i}"`.
- **A null `Bool?` in `&&`, `||`, `if` and `while` throws** instead of counting as false.
- **A null `String` on either side of `+` throws "Null reference"** instead of crashing.
- **`==`, `!=` and `!!` after a safe-call chain apply to the chain's result.** `z?.n == null` is true when `z` is null. It used to be false, and `a?.b?.n!!` used to give 0 instead of throwing.
- **Byte is signed everywhere.** It was a plain C `char`, which is unsigned on ARM and PowerPC, so `-128B` read back as 128 there. Hand-written natives that take a Byte should use `signed char`.
- **A test run in which no test ran fails** with `Error: no tests were run` and exit status 1.
- **Git dependencies need `git` on `PATH`.** They are fetched with the system `git` instead of the bundled JGit; `-git-path` names another executable.
- **Some sloppy source is now a parse error:**
  - a literal right after a complete statement (`var a = 1 2`);
  - a stray `)`;
  - an unclosed string literal (the compiler used to hang on one);
  - a stray word in a class body;
  - `() => Void` (write `() => void`).

## Fixes

Most of these compiled without an error or warning and produced wrong code.

- **Wrong values:**
  - A nullable primitive passed, returned or assigned as another nullable type kept its old box: `-5` as `Int?` read as 4294967291 in a `Long?`.
  - A null `Int?` compared with a value read stack garbage, and `new Int?[n]` elements read as 0.
  - A member read after `!!` or `?.` could take a local of the same name.
  - `f!!(args)` didn't call `f`.
- **Crashes in generated code:**
  - Comparing an `Any` that holds a primitive with an object segfaulted.
  - A suspending constructor argument segfaulted.
  - A suspend call on the right of a safe-call compound assignment crashed or left the target unchanged.
  - `+=` on a fresh `Int?[]` element segfaulted.
- **Leaks and use-after-free:**
  - A value through a safe-call chain leaked in many positions (stored, passed, returned, in a template or `??`).
  - A discarded call result and an assignment's temporary were held until the block ended.
  - Storing a value into its own slot (`b.kid = b.kid`, `r = r`) could free it.
  - A suspension inside a loop leaked the objects held by the blocks around it.
  - A suspend function call leaked its receiver.
- **Expressions that now work:**
  - `x++` and `x--` as a value inside any expression, on array elements and on `Int?`.
  - A nullable primitive as the operand of any operator.
  - A `<` written against a name (`i<n`, `x<<2`), which was read as type arguments.
  - `"${...}"` templates with operators.
  - `List<Any>` and `HashMap<String, Any>`.
  - A bare call in a compound assignment's index (`arr[take(1)] += 1`) and on the right of an assignment.
  - A generic function called without its class name (`lenOf<Int>(xs)`).
- **Exceptions that were lost:**
  - An exception thrown by a property initializer or an `init { }` block now reaches the code around the `new`.
  - An exception inside a `suspend(cont) { }` block now reaches the caller.
  - An exception from a null check or a bounds check in a function inferred not to throw now reaches the caller.
- **Compiler and tools:**
  - `amlc build` no longer hangs when gcc writes a lot to stderr.
  - Every `namespace` block in a file is compiled, not only the first.
  - A `package.yml` with a missing key gives an error that names the file, not a Java stack trace.
  - `amlc test` copies `tests/assets` next to the test binary.
  - With `treeShake: true`, tests are no longer removed.
  - Generated C uses LF line endings and the same order on every run.
  - A class with an object property builds with gcc 6.5 (m68k-amigaos, ppc-morphos).
- **Clearer errors:** an undefined name, a missing import, a private function and a static function of a generic class that uses the class's type parameter now each give one error that names the cause, with file and line.

The full list is in the changelog.

## Upgrading to v0.16.0

1. **Upgrade `am-lang-core` to 0.16.0.** It is built and tested with this compiler and adds `ArithmeticException`, `String.compareTo`, path style conversion and `TaskScheduler.runAsync`.
2. **Fix the new compile errors.**
   - **Hex suffixes:** drop the suffix where the type is given; elsewhere use `as`.
   - **String comparisons:** replace `<`/`>` on strings with `compareTo`.
   - **String concatenation:** add `.toString()` or use a template where a non-String is added to a String.
   - **`#noThrow` overrides:** put a `try`/`catch` in a `toString`, `hash` or `equals` override that can throw.
   - **Type arguments:** convert `Int[]` and similar where a different element type is expected.
3. **Remove `catch` blocks for `OutOfMemoryException`.** They never run now; the program shuts down instead.
4. **Update scripts that read build output.** Use `builds/<targetId>/bin/app` instead of `builds/bin/<platform>/app`, and `test-builds/<targetId>/`. Clear an old build folder's object directory once.
5. **Check code that relied on old behaviour:**
   - a `Long + Int` that was silently cut to an Int;
   - `?.x == null` that was false;
   - a null `Bool?` treated as false;
   - Byte arithmetic on ARM or PowerPC.
6. **Make sure `git` is on `PATH`** if you use git dependencies, and that every package you run with `amlc test` has tests.
7. **Run your tests.** `amlc test` now checks integer division, so a division by zero that used to pass silently shows up as an `ArithmeticException`.

## Known limitations

- **Operators other than `==`, `!=` and `!!` after a safe-call chain stay inside the chain.** `a?.n < 5` is false when `a` is null.
- **Writing a captured local inside a lambda writes a copy.** The enclosing function's local is unchanged, and the written value leaks.
- **Some failures inside lambdas in generic code:** `new List<T>()`, the class's imports and `var copy: T = v` inside a lambda in a generic class or function can fail to compile.
- **An unchecked build's division by zero is undefined behaviour in C.** gcc may assume the divisor isn't zero, so a later `b == 0` test can be optimized away. Test with `amlc test`, which checks.

## Full changelog

See [CHANGELOG_v0.16.0.md](CHANGELOG_v0.16.0.md) for every change since v0.15.0.
