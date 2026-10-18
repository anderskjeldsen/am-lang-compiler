# AmLang Compiler v0.14.0 Changelog

## [0.14.0] - Unreleased

Changes since v0.13.0.

### Added

- **`shared static` properties.** One copy for the whole PROCESS, readable and writable from every thread, instead of the per-isolate copy a plain `static` gets. Each one is emitted as its own C global, and a plain primitive is stored as its own C type — an `Int` is an `int`, not a tagged `nullable_value`. A nullable primitive keeps its tag.

  UNSYNCHRONISED BY DESIGN: no lock, no atomic, no ordering guarantee. A reader on another thread may see a stale value, and a 64-bit type can tear on a 32-bit target such as m68k or PPC32. Guarding it is the caller's job; `Am.Threading.Mutex` is there for that.

  Restricted to primitives, and each restriction is diagnosed rather than ignored: an object or struct is refused, because one process-wide copy would hand a pointer into one isolate's heap to another thread; an initializer is refused, because the global is already zero at load time and a process-wide slot must not be re-initialised by every isolate (assign in `main` before starting threads); and `shared` is refused on an interface, which has no statics at all. `shared` is contextual, so it stays usable as an ordinary identifier.

- **Share-nothing isolate threads.** Static properties live per isolate, addressed through the class's static slot base, and startup emits the static initializer table and boots the main isolate. `Thread.send`/`receive` deep-copy messages between isolates; native classes opt in with `#sendable` (String, Array, Thread) and supply a native copy hook. String constants and annotations are immortal.

- **Fast-lane arenas.** The isolate carries a bump arena used by the allocation scopes below, reclaimed by reference count rather than by scope, so an object that escapes its scope stays correct and only costs retention.

- **Reflection by `#reflect` closure, replacing the `-reflection` flag.** An annotated class gets a read-only descriptor hung on its `aclass`: its properties with name, slot, nullability and declared type, its type arguments, its instance initializer, and a thunk per invokable instance method. `ClassRef` and `PropertyInfo` are built from it lazily, so startup spends nothing, and an unreflected class still answers `getClassRef()` with its name. `-reflection=all` annotates everything.

- **`main` may return `Int`**, and the value becomes the process exit status. A throwing `main` now exits 1 rather than 0, and a throwing `#runOnExit` hook turns a 0 into 1 without overriding a non-zero status `main` set itself.

- **Property-slot initialisation is decided per class, with no flag.** A class whose slots all start as zero bytes gets the allocator's `memset` and nothing else — no `___init_instance` call, since a property that starts as null needs nothing done to it. A class whose starting state is a compile-time constant gets a per-variant `const property` image, memcpy'd by the primary constructor, with the prepared allocator and no init call. A class whose starting state has to be computed keeps `___init_instance` as before.

  This replaces the opt-in `-ftemplate-properties` and the separate inline-defaults path. Measured on am-git: binary 4,087,696 to 4,079,920 bytes (-0.19%, because only 19 variants need an image where the blanket flag emitted 211), and an 18-slot allocation loop 217ms to 207ms. The flag is still accepted so existing build scripts keep working, but it no longer selects anything.

  Still unmeasured on m68k, where a memcpy is a libc call with no wide stores; and there is no slot-count threshold yet, so a two-slot class gets an image where two stores would do.
- **`-fseed-properties` (opt-in, and measured as not worth enabling).** The generated constructors seed every property slot nothing else assigns, so the allocator need only clear the object header. Kept in tree with its measurements so the experiment is not repeated. It also carries a documented invariant hole: three native paths allocate an object without running a constructor, so with the allocator no longer clearing, a property with no initializer is left as heap garbage.

- **`-fescape-report` (prototype, report only).** Census of `new` sites whose object provably cannot outlive its function, as groundwork for promoting them to the arena automatically. Nothing is promoted and the pass runs only under the flag.

- **Allocation scopes.** `scratch { ... }` bump-allocates every object created while the block runs — in callees too, since the switch is a counter on the isolate rather than a lexical region — from the isolate's arena, and reclaims the arena once the objects in it have died. `keep { ... }` is the inverse: it forces the normal heap inside a scratch extent, for objects meant to outlive the block. Both have an allocation-level form, `scratch new T(...)` and `keep new T(...)`, which scopes argument evaluation and the constructor as well as the allocation. The words are contextual, so `scratch`, `keep` and `fast` remain usable as ordinary identifiers.

  An object that outlives a `scratch` block is still correct, but it pins its whole arena until it dies — which is what `keep` exists to avoid. `keep` outside any scratch extent is a no-op, so library code whose allocation is long-lived by design (an interning table, a memo cache, a registry) can use it defensively to stay out of whichever arena its caller happens to have open.

  `fast { ... }` is accepted as the legacy spelling of `scratch { ... }`. The old name described the reward rather than the precondition, which invited applying it to code whose objects survive — the one case it does not help.

- **`#keepAlways` class directive.** Instances of an annotated class never come from a scratch arena, whatever extent is open. It is **inherited**, so the single annotation on `Am.Lang.Exception` covers every exception subclass in core and in user code. `scratch new T(...)` on such a class is rejected rather than silently ignored.

  This is a runtime flag on the class rather than a compile-time rewrite, because the runtime throwers — `__create_exception` and the packed null/bounds/size/OOM site helpers — allocate from C with no `new` site to annotate. Without it, a `throw` out of a `scratch { }` block left the exception in the arena, holding the whole arena for as long as the exception lived.

  Intended for classes whose instances escape by construction or are long-lived by design. It is a per-class, global decision: applying it to something like a map entry would silently disable arena allocation for every such object.

### Changed

- **Arena bookkeeping is O(1) per detach.** The runtime's arena list is doubly linked, so handing an empty arena back no longer scans the isolate's list from the head. This matters once a program holds hundreds of arenas.

- **Borrowed property-slot reads, unconditionally.** A slot read whose window to its last use is call-free skips the retain and release pair, since the property cannot be replaced underneath it. Measured at 30% on the HashSet insert path. This supersedes the `-fborrow-slot-reads` flag, which is no longer read.

### Fixed

- **`amlc docs` lists `shared static` properties**, labelled as such rather than as plain statics, so the per-isolate/process-wide distinction is visible to a reader.

- **`PRIMITIVE_NULL` stamping in the primary constructor.** The stamp loop counted its own ordinal from zero over the class's own property list, so every class with a property-owning base wrote its local ordinals into the base's slots.

- **A name followed by a call binds to the method, not a same-named field.** `map.keys()` bound to `HashMap`'s private `keys` array and then failed to call it, while a differently named method worked.

- **Generics inference, lambda `this` capture, `Any` null operations and chain fixes.** Recursive bounds no longer trip over a class whose base and interface links are still being populated, a `null` literal passed to an `Any` parameter is accepted when the parameter's type carries only a referred class, and `new T().primitiveFn()` no longer declares its box twice.

- **Test binaries of packages that use `shared static` link.** The process-wide globals were defined in the application startup only, so the test startup referenced `<Class>_SS_<name>` symbols that did not exist and the test binary failed to link — while amlc still exited 0.
- **Test startup declares `exit_code`.** The exit-hook failure path is emitted by the test startup too, where the variable did not exist, so any package with a `#runOnExit` hook failed to compile its test binary.
