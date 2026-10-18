# AmLang v0.14.0 Release Notes

**Release Date:** 2026-10-18

v0.14.0 makes threads share nothing. Static properties now live per isolate, messages between isolates are deep-copied, and each isolate carries a bump arena that the new allocation scopes draw from. Around that sit a reflection model that costs nothing at startup, an exit status from `main`, and two opt-in allocation experiments, one of which pays and one of which is kept only so nobody repeats it.

**Upgrade attention:** this release requires the matching `am-lang-core` runtime. The generated code addresses per-isolate statics, the immortal object flag and new `aclass` fields, none of which exist in an older core. Upgrade both together.

## Share-nothing isolate threads

Each isolate owns its static properties, addressed through the class's static slot base rather than through globals, and startup emits the static initializer table and boots the main isolate before anything runs.

`Thread.send` and `Thread.receive` deep-copy the message, so no object graph is shared between isolates. Native classes opt in with `#sendable`, which is set on `String`, `Array` and `Thread`, and supply a native copy hook. String constants and annotations are immortal, so they need no copying at all.

## `shared static`: one copy for the whole process

Because statics are now per isolate, two threads writing the same `static`
touch different memory and never see each other's value. `shared static` is how
you ask for one copy instead:

```aml
class Counters {
    shared static var total: Int
}
```

Every thread reads and writes the same `total`. It is emitted as its own C
global, and a plain primitive is stored as its own C type, so an `Int` is an
`int` rather than a tagged `nullable_value` — four bytes instead of sixteen and
one word to load or store. A nullable primitive keeps its tag, since `Int?`
needs it to represent null.

**It is unsynchronised, deliberately.** No lock, no atomic, no ordering
guarantee. A reader on another thread may see a stale value, and a 64-bit type
can tear on a 32-bit target such as m68k or PPC32, giving half of each of two
values. Guard it yourself with `Am.Threading.Mutex` when that matters.

Primitives only, and each refusal names its reason. An object or struct is
rejected because one process-wide copy would hand a pointer into one isolate's
heap to another thread, which is what the share-nothing model exists to
prevent. An initializer is rejected because the global is already zero at load
time and a process-wide slot must not be re-initialised by every isolate;
assign it in `main` before starting threads if you want another starting
value. `shared` on an interface is rejected, since interfaces have no statics.

`shared` is a contextual word, not a reserved one, so existing code that uses
`shared` as an identifier keeps compiling.

## Allocation scopes

`scratch { ... }` bump-allocates every object created while the block runs, in callees too, because the switch is a counter on the isolate rather than a lexical region. The arena is reclaimed once the objects in it have died.

`keep { ... }` is the inverse. It forces the normal heap inside a scratch extent, for objects meant to outlive the block. Both have an allocation-level form, `scratch new T(...)` and `keep new T(...)`, which scopes argument evaluation and the constructor as well as the allocation. All three words are contextual, so `scratch`, `keep` and `fast` remain usable as identifiers, and `fast { ... }` is accepted as the legacy spelling.

An object that outlives a `scratch` block is still correct. It pins its whole arena until it dies, which is the cost, and `keep` is how you avoid it. Outside any scratch extent `keep` is a no-op, so library code whose allocation is long-lived by design, such as an interning table or a registry, can use it defensively to stay out of whichever arena its caller happens to have open.

`#keepAlways` on a class means its instances never come from an arena, whatever extent is open. It is inherited, so the single annotation on `Am.Lang.Exception` covers every exception subclass, and `scratch new` on such a class is rejected rather than ignored. It exists because the runtime throwers allocate from C with no `new` site to annotate, and without it a `throw` out of a scratch block held the whole arena for as long as the exception lived.

Measured at roughly 25 to 30% faster on an allocation-saturated loop. Arena detach is O(1), because the arena list is doubly linked.

## Reflection by `#reflect` closure

The `-reflection` flag is replaced by a directive. A class marked `#reflect` gets a read-only descriptor hung on its `aclass`: its properties with name, slot, nullability and declared type, its type arguments, its instance initializer, and a thunk per invokable instance method. `ClassRef` and `PropertyInfo` are built from that lazily, so startup spends nothing, and a class that is not reflected still answers `getClassRef()` with its name. `-reflection=all` annotates everything.

## `main` may return `Int`

The returned value becomes the process exit status. A throwing `main` now exits 1 rather than 0, and a throwing `#runOnExit` hook turns a 0 into 1 without overriding a non-zero status `main` set itself.

## Property slots start the way the class needs, and nothing more

How a new object's property slots reach their starting state is now decided per
class, with no flag:

- **All slots start as zero bytes** — every property is an object or starts as
  null — so the allocator's `memset` IS the starting state. No image, no
  `___init_instance` call. A property that starts as null needs nothing done to
  it.
- **The starting state is a compile-time constant** — any primitive (its flags
  byte carries the type tag), a nullable primitive (`PRIMITIVE_NULL`), a literal
  default. The variant gets a `const property` image, the primary constructor
  memcpy's it in, the `new` site uses the prepared allocator, and the init call
  is dropped.
- **The starting state has to be computed** — a string constant, a `new`, a
  call, a struct property, an `init { }` block, a native base — and
  `___init_instance` runs exactly as before.

Measured on am-git:

| | before | after |
|---|---|---|
| binary | 4,087,696 | 4,079,920 (−0.19%) |
| variants needing an image | — | 19 |
| 18-slot allocation loop, 4M objects | 217 ms | 207 ms |

The binary gets *smaller* because the image is now emitted only where it
displaces work. The opt-in `-ftemplate-properties`, which emitted one for every
eligible variant, cost +0.98% on the same program — 211 images, most of them
copying zeros over zeros that the allocator had already written.

Two shapes were tried and rejected on the way: an image *plus* `___init_instance`
re-applying every default through `__set_property` (25% slower — work on top of
the work the copy was meant to remove), and an image for every variant including
the all-zero ones.

`-ftemplate-properties` is still accepted so existing build scripts keep
working, and now selects nothing.

**Not yet measured on m68k**, which is the target that matters most: a memcpy
there is a libc call with no wide stores and the rodata costs real memory. There
is also no slot-count threshold, so a two-slot class gets an image where two
stores would do.

**`-fseed-properties` remains opt-in and still does not pay.** It lets the generated constructors seed every slot nothing else assigns, so the allocator need only clear the object header. It is kept in tree with its measurements so the experiment is not repeated, and with a documented hole: three native paths allocate an object without running a constructor, so with the allocator no longer clearing, a property with no initializer is left as heap garbage.

**`-fescape-report`** is a report-only census of `new` sites whose object provably cannot outlive its function, as groundwork for promoting them to the arena without a hand-written `scratch new`. Nothing is promoted.

## Faster property reads

A property-slot read whose window to its last use is call-free now skips the retain and release pair, since the property cannot be replaced underneath it. Measured at 30% on the HashSet insert path. This is unconditional and supersedes `-fborrow-slot-reads`, which is no longer read.

## Fixes

- `PRIMITIVE_NULL` stamping wrote a subclass's local property ordinals into its base's slots.
- A name followed by a call now binds to the method rather than a same-named field, so `map.keys()` no longer binds to a private array and fails to call it.
- Recursive generic bounds no longer trip over a class whose base and interface links are still being populated.
- A `null` literal passed to an `Any` parameter is accepted when the parameter's type carries only a referred class.
- `new T().primitiveFn()` no longer declares its box twice.
- The test startup declares `exit_code`, which the shared exit-hook emitter referenced; any package with a `#runOnExit` hook previously failed to compile its test binary.

## Upgrading to v0.14.0

1. **Upgrade `am-lang-core` to the matching release.** This is not optional. The generated code addresses per-isolate statics, the immortal object flag and new `aclass` fields, none of which exist in an older core. A mismatched pair fails at the C compile, usually on a missing `aobject` or `aclass` member.
2. **Audit statics that were shared between threads.** A plain `static` is now one copy *per isolate*, so two threads writing it no longer see each other's value — silently, with no diagnostic. Move genuinely shared primitive state to `shared static` and guard it yourself, or pass it in a message.
3. **Audit what you send between threads.** `Thread.send`/`receive` deep-copy, and a native class that has not opted in with `#sendable` is refused at runtime. `String`, `Array` and `Thread` are opted in.
4. **Replace `-reflection` with `#reflect` where you can.** The flag still works and now means "reflect everything"; the directive reflects one class and its closure, which is what keeps startup free.
5. **Drop `-fborrow-slot-reads` and `-ftemplate-properties` from build scripts.** Borrowed property-slot reads are unconditional now, and property-slot initialisation is decided per class; neither flag is read any more. Both are still accepted, so a stale script does not break.
6. **Prefer `scratch { }` to `fast { }`.** The old spelling still compiles; the new one names the precondition rather than the reward.
7. **Check `main`'s return type if you have one.** An `Int` return is now the process exit status, and a throwing `main` exits 1 instead of 0.

## Known limitations

- **`shared static` is unsynchronised and primitives only.** No lock, no atomic, no ordering guarantee; 64-bit types can tear on 32-bit targets. Objects, structs and initializers are rejected by design.
- **An object that escapes a `scratch` block pins its whole arena** until it dies. That is correct but can hold far more memory than the object itself; `keep` is the way out, and `#keepAlways` covers classes that escape by construction.
- **No slot-count threshold for property images.** A two-slot class gets an image where two stores would do, and the measurements are arm64 only — on m68k a memcpy is a libc call with no wide stores.
- **`-fseed-properties` is not recommended.** It is kept only so the experiment is not repeated, and it carries a known invariant hole around the three native paths that allocate without running a constructor.
- **`-fescape-report` promotes nothing.** It is a census, not an optimization.

## Full changelog

See [CHANGELOG_v0.14.0.md](CHANGELOG_v0.14.0.md) for the detailed changes since v0.13.0.
