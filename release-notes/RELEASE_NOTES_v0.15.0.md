# AmLang v0.15.0 Release Notes

**Release Date:** 2026-11-07

v0.15.0 is mostly about the language. It adds overloading by parameter type, `when` with smart casts, `data class`, `if` and `when` as expressions, default parameter values with named arguments, and the full set of compound assignments. It also changes what `for (i = a to b)` means, and makes `amlc` exit with a failure status when something fails. Many of the fixes are code that compiled without complaint and did the wrong thing.

**Upgrade attention:** two changes need action. `to` in a `for` loop now includes its end, and `amlc` now exits 1 on failure. Upgrade `am-lang-core` to 0.15.0 at the same time; see [Upgrading](#upgrading-to-v0150).

## `for` loops: `to` includes the end, `until` stops before it

```aml
for (i = 0 to 3) { }      // 0, 1, 2, 3
for (i = 0 until 3) { }   // 0, 1, 2 — what `to` used to do
```

This is a breaking change. A loop that indexes an array with `to`, such as `for (i = 0 to arr.length())`, now runs one pass too many. The compiler warns when a `to` loop's end is a `size`, `length` or `count` read or call, including on builds that succeed. Every `to` loop in the AmLang projects has been rewritten to `until`, so their behaviour is unchanged. am-script follows the same rule, and its `.amsb` cache version is now 19.

## Overloading by parameter type

Functions can now share a name and a parameter count if their parameter types differ. A call picks the best match from the static types of its arguments, in this order:

1. the exact class;
2. the nearest subclass;
3. numeric widening;
4. `Any`, generic, function-typed or `null`.

Virtual and interface overloads are dispatched at run time.

Before this release, the second declaration was rejected as "already exists". Every call went to the first function with that name and count.

## `when`, with smart casts

```aml
when (shape) {
    is Circle -> area = shape.r * shape.r * 3
    is Rect -> area = shape.w * shape.h
    else -> area = 0
}
```

In an `is T` branch the subject is typed `T` without a cast. This works for class, interface and `Any` subjects, and also for field writes through the subject.

- Branches can also be values (`1, 2 ->`) or `!is T`.
- Branches are tried from top to bottom, and the first match wins.
- The subject is evaluated only once.
- `when { cond -> … }` without a subject also works.

`when` stays usable as an identifier.

## `if` and `when` as expressions, and expression bodies

```aml
var sign = if (x < 0) "neg" else "pos"
fun area(): Int = this.w * this.h
```

- Only the chosen branch runs.
- The `else` is required.
- A `null` branch makes the result type nullable.
- `when` also works as a value, with single-expression branches, an `else` and a plain-variable subject.

## `data class`

```aml
data class Point(var x: Int, var y: Int)
```

The class gets generated `equals`, `hash`, `toString` (`Point(x=1, y=2)`) and `copy()`, all based on its primary-constructor properties. Value comparison and hash-based collections therefore work without hand-written `equals` and `hash` pairs. Members the class declares itself take precedence over the generated ones. Generic data classes work too.

## Default parameter values and named arguments

```aml
fun label(text: String, size: Int = 12, bold: Bool = false)
label("Hi")
label("Hi", bold = true)
new Pt(y = 7, x = 2)
```

- Defaults are constants: a literal or `null`.
- Parameters with defaults come after the ones without.
- An overload that matches the exact number of arguments wins over one that needs a default.

## Operators and compound assignment

- **New compound assignments:** `*=`, `/=`, `%=`, `&=` and `^=` join `+=`, `-=` and `|=`. They work on:
  - locals, properties and statics;
  - array elements;
  - nullable primitives;
  - classes that declare the matching operator.
- **New operator functions:** `op /`, `op %`, `op &`, `op |` and `op ^` can now be declared.
- **`const` properties are now enforced.** `const x: T` in a primary constructor declares a read-only property.

## `amlc` reports failure

`amlc` used to exit with status 0 even when it failed. It now exits 1 in these cases:

- a compile error;
- a failed `make`, docker or ssh build;
- a failing test;
- an unknown command;
- a program that failed under `run`.

Two further changes:

- **An unknown `-bt` is an error.** If `-bt` names a build target the package doesn't define, `amlc` lists the defined targets. Before, it silently did nothing.
- **The old executable is removed before every build**, so a failed build can't leave a stale binary that looks like a working one.

Platforms can now inherit their toolchain. A platform with no `gccCommand` takes the C compiler, assembler and linker commands from the platforms it extends, so a variant such as `amigaos-minigl` only needs `extends: amigaos`.

`amlc test` now builds tests the way `amlc build` builds the program:

- it uses the platform's `linkerCommand`;
- it collects `gccAdditionalOptions` from parent platforms and dependencies;
- it applies `gccRemoveOptions` and the enabled features' options.

## Fixes

Most of these compiled without an error or warning and produced wrong code.

- **Missing code and checks:**
  - `init { }` blocks and property initializers were never validated, so an unknown call in them built successfully and was silently left out of the generated C.
  - A field write through a parenthesised cast, `(st as Label).text = text`, assigned the parameter to itself instead of writing the field.
- **Wrong values:**
  - The right side of `+=`, `-=` and `|=` was cut short at the next `+` or `-`, so `a += 1 + 2` added 1.
  - `arr[i] += 5` dropped the update.
  - `a - b == 1` parsed as `a - (b == 1)`.
  - A static initializer could run before the statics it reads, and read 0.
  - `s?.length()` on a null `s` read as 0 instead of null.
- **0.14.0 regressions:**
  - Object property defaults such as `var name: String = "x"` were not applied, which left the field NULL.
  - `var b: Base = new Derived()` skipped `Derived`'s property defaults.
- **Errors that are now accepted:**
  - Calling an instance method or reading a property without `this.` failed or crashed the renderer. It now binds to `this`.
  - `obj.p = a && b` emitted C that didn't compile.
  - Declaring the same local name in sibling `try` and `finally` blocks failed.
  - A compound assignment to an `Int?` emitted C that didn't compile.

The full list is in the changelog.

## `requiredStack`: a stack check at startup

```yaml
buildTargets:
  - id: amigaos
    platform: amigaos
    requiredStack: 65536
```

Before anything else runs, the program compares this number with the stack it actually has. If the stack is smaller, it prints the size needed (`Use: Stack 65536`) and exits with status 20, which stops a script at the default `FailAt`. The check applies to the Amiga family only and does nothing elsewhere. The compiler can't work out the number for you, so measure it.

## Upgrading to v0.15.0

1. **Rewrite `to` loops that stop before their end to use `until`.** Anything that indexes `0 to length` is now off by one, so start with the compile-time warnings. A `to` loop whose end is a variable or expression isn't warned about, so review those by hand.
2. **Upgrade `am-lang-core` to 0.15.0.** Its loops are written with `until`, which older compilers don't know. Its 0.14.0 loops would run one pass too many under this compiler.
3. **Check scripts and CI that call `amlc`.** A non-zero exit status now means a real failure, and `amlc test` exits 1 when any test fails. A script that relied on the old status 0 will now stop.
4. **Fix code that was being silently dropped.** Validating `init` blocks and property initializers turns previously silent errors into compile errors. am-ide, tucan-mail and tucan-paint each had such lines.
5. **If you call an AmLang `op -` by its C symbol, use `_op__minus`.** It used to be compiled under `op /`'s name. This includes am-script's `ScriptOperators`.

## Known limitations

- **`when` as an expression is narrower than the statement.** Its branches must be single expressions, an `else` is required, and its subject must be a plain variable.
- **Default parameter values must be constants.** An expression or a call isn't accepted.
- **Two classes whose static initializers read each other keep their declaration order.** The compiler warns about it.

## Full changelog

See [CHANGELOG_v0.15.0.md](CHANGELOG_v0.15.0.md) for every change since v0.14.0.
