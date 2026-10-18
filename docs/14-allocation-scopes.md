# Allocation Scopes

Introduced in v0.14.0.

Most objects a program creates are short-lived: a parsed row, a formatted
string, an intermediate list. They are allocated individually, reference
counted individually, and freed individually. An allocation scope lets you say
in one place that a region of work produces such objects, so the runtime can
hand them out of a bump arena instead.

## `scratch`

`scratch { ... }` bump-allocates every object created while the block runs from
the isolate's arena, and reclaims the arena once the objects in it have died.

```amlang
scratch {
    var doc = MdParser.parse(source)
    var summary = doc.summarize()
    results.add(keep new Summary(summary))
}
```

The switch is a **counter on the isolate**, not a lexical region, so it covers
objects allocated by functions the block calls — including library code that
knows nothing about scopes. That is what makes it useful on a parse or a render
pass, where most of the allocation happens several frames down.

There is also an allocation-level form, which scopes argument evaluation and the
constructor as well as the allocation itself:

```amlang
var row = scratch new Row(name, value)
```

### Escape is safe, but it pins

An object that outlives its `scratch` block is still **correct** — arenas are
reclaimed by reference count, not by scope exit. The cost is that the escaping
object pins its whole arena until it dies. One long-lived string can therefore
hold the memory of every object allocated alongside it.

That is the precondition the feature asks you to check: use `scratch` where the
work is genuinely transient, not merely hot.

## `keep`

`keep` is the inverse. It forces the normal heap inside a scratch extent, for
the objects meant to outlive the block:

```amlang
scratch {
    var parsed = parse(line)             // arena
    cache.put(key, keep new Entry(parsed.value))   // heap, survives the block
}
```

`keep { ... }` and `keep new T(...)` both exist, mirroring `scratch`.

Outside any scratch extent `keep` is a **no-op**, which is what makes it usable
defensively: an interning table, a memo cache or a registry can wrap its own
allocations in `keep` and stay out of whichever arena its caller happens to have
open.

## `fast`

`fast { ... }` is the legacy spelling of `scratch { ... }` and still compiles.
The rename happened because the old name described the reward rather than the
precondition, which invited applying it to code whose objects survive — the one
case where it does not help.

## `#keepAlways`

Some classes escape by construction. Annotate the class, and its instances never
come from an arena, whatever extent is open:

```amlang
#keepAlways
class Exception { }
```

The directive is **inherited**, so the single annotation on `Am.Lang.Exception`
covers every exception subclass in core and in user code. `scratch new T(...)`
on such a class is rejected rather than silently ignored.

It is a runtime flag on the class rather than a compile-time rewrite, because
the runtime's own throwers — `__create_exception` and the packed null, bounds,
size and out-of-memory site helpers — allocate from C, with no `new` site to
annotate. Without it, a `throw` out of a `scratch { }` block left the exception
in the arena, holding that arena for as long as the exception lived.

Use it for classes whose instances escape by construction or are long-lived by
design. It is a per-class, global decision: applying it to something like a map
entry would silently disable arena allocation for every such object in the
program.

## Keywords are contextual

`scratch`, `keep` and `fast` are contextual keywords: existing code that uses
any of them as a variable, parameter or method name keeps compiling.

## Related

- [Keywords Reference](./03-keywords.md) — the spellings
- [Threading and Concurrency](./11-threading.md) — isolates, which own the arenas
- [Compiler Usage](./16-compiler-usage.md) — `-fescape-report`, which lists `new`
  sites whose object provably cannot outlive its function
