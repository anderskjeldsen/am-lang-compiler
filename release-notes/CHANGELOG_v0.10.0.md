# AmLang Compiler v0.10.0 - Changelog (Working Document)

**Status:** In Progress  
**Major Theme:** Struct Improvements

---

## Improvements

### Struct Value Comparison (`==` / `!=`)

Previously, using `==` or `!=` on struct values performed a pointer comparison (identity check), meaning two independently constructed structs with identical field values would not be considered equal.

Structs now support field-by-field value comparison when using `==` and `!=`.

#### How it works

For each struct type, the compiler generates a `_equals()` helper function in C that compares every field:

```c
bool ExampleTests_Vector3_equals(struct ExampleTests_Vector3 *a, struct ExampleTests_Vector3 *b) {
    if (a == b) return true;
    return a->x == b->x && a->y == b->y && a->z == b->z;
}
```

Nested structs are handled recursively:

```c
bool ExampleTests_Transform_equals(struct ExampleTests_Transform *a, struct ExampleTests_Transform *b) {
    if (a == b) return true;
    return ExampleTests_Vector3_equals(&a->position, &b->position)
        && ExampleTests_Point2D_equals(&a->offset, &b->offset);
}
```

Function declarations are emitted in the `.h` file alongside the struct typedef.

#### AmLang usage

```amlang
var a: Point2D = { x: 5, y: 10 }
var b: Point2D = { x: 5, y: 10 }

if (a == b) {
    // true — field-by-field comparison
}
```

Nested structs and deeply nested structs are also supported:

```amlang
var a: Transform = { position: { x: 1.0F, y: 2.0F, z: 3.0F }, offset: { x: 10, y: 20 } }
var b: Transform = { position: { x: 1.0F, y: 2.0F, z: 3.0F }, offset: { x: 10, y: 20 } }

if (a == b) {
    // true
}
```

#### Test coverage

Ten unit tests added in `examples/unit-testing/tests/StructComparisonTest.aml`:

- Equal flat structs (`Point2D`)
- Not-equal flat structs
- Equal after assignment
- Not-equal after field modification
- Equal float structs (`Vector3`)
- Not-equal float structs
- Equal nested structs (`Transform`)
- Not-equal nested structs
- Equal deeply nested structs (`PhysicsState`)
- Not-equal deeply nested structs

---

## TODO / Open Items

- [ ] Verify behavior with struct arrays
- [ ] Verify behavior with struct fields that are interfaces/classes (pointer types)
