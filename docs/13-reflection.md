# Reflection

Every value answers `getClassRef()` with the `ClassRef` of its run-time class, and that always
carries the class name:

```amlang
"hello".getClassRef().getClassName()      // "Am.Lang.String"
someObject.getClassRef().isReflected()    // false unless the class is reflected
```

A class marked `#reflect` also exposes its instance properties, can be looked up by name and
can be instantiated:

```amlang
#reflect
class Order(var id: Int, var customer: Customer) {
    var lines: List<OrderLine> = List<OrderLine>.newList<OrderLine>()
    var note: String? = null
    var shipTo: Address? = null
}
```

`#reflect` is transitive. Marking `Order` reflects its **closure**: its base classes, the declared
types of its properties with their type arguments (`Customer`, `List<OrderLine>` and
`OrderLine`), and every subclass of a reflected class (a `HomeAddress` stored in the `Address`
property). Nothing outside the closure pays for reflection: a reflected class costs a few hundred
bytes of read-only descriptor data; the `ClassRef` and `PropertyInfo` objects are built on first
use and shared by all threads for the life of the program. `Object`, `Any` and the primitives are
never part of a closure. The old `-reflection` compiler flag now simply reflects every class.

## Reading

```amlang
var cr = order.getClassRef()
each (p in cr.getProperties()) {                       // slot order, base classes first
    var v = p.getValue(order)                          // Any: boxed primitive, object, or null
    (p.getName() + ": " + p.getPropertyClassRef().getClassName()).println()
}
cr.getProperty("note").isNullable()                    // true
cr.getProperty("lines").getPropertyClassRef().getTypeArguments()[0UI].getClassName()
                                                       // "OrderLine" (with its namespace)
```

`getPropertyClassRef()` is the *declared* type; the value's own `getClassRef()` may be a subclass.

## Writing and constructing

```amlang
var cr = ClassRef.getClassRef("Shop.Customer")         // by name - reflected classes only
var c = cr.newInstance()                               // allocated, property defaults applied,
                                                       // constructor NOT run
cr.getProperty("name").setValue(c, "Bob")
cr.getProperty("age").setValue(c, 42L)                 // numeric primitives are converted
```

`setValue` checks an object against the property's declared class and converts numeric
primitives to the slot's kind; `null` is accepted only by nullable properties.

Arrays are handled through the array type's `ClassRef` (what `getPropertyClassRef()` returns for
an `Int[]` or `Person[]` property):

```amlang
var arr = ClassRef.newArray(cr.getProperty("codes").getPropertyClassRef(), 3)
ClassRef.arraySet(arr, 0, 10)
ClassRef.arrayGet(arr, 0)                              // Any
ClassRef.arrayLength(arr)
```

## Calling methods

A reflected class's instance methods can be called by name, which is how a serializer uses a
collection's own API instead of reaching into its storage:

```amlang
var args = new Any[1UI]
args[0UI] = newLine
ClassRef.invoke(list, "add", args)                     // list.add(newLine)
var n = ClassRef.invoke(list, "getSize", new Any[0UI]) as Int
```

Arguments are converted to the method's declared parameter types (numeric primitives included),
the return value comes back as `Any` (null when the method returns nothing), and an exception
thrown inside the method propagates to the caller. Overloads are matched by name and argument
count, so two overloads with the same arity cannot be told apart here. Static, native, generic,
suspend, inline and extension functions are not invokable, nor is anything passing or returning
a struct.

## What is not reflected

Static properties and the internals of native classes (a `String`'s characters are
reached through its normal API). Properties declared `Any` or as an interface are reflected, but
what they hold is only as reflectable as its own class. Generic classes are reflected per
variant: `List<OrderLine>` is `"Am.Collections.List_ta_Shop.OrderLine"` by name.

## JSON

`am-json` builds on all of this: `Json.serialize(value)` and `Json.deserialize<T>(text)` walk a
reflected object graph, mapping `List<T>`, `T[]`, `HashSet<T>` and `TreeSet<T>` to JSON arrays
and `HashMap<String, V>` to a JSON object, through those types' own methods. A `TreeSet` is
written (in its sorted order) but cannot be read back: its comparator comes from the constructor,
which `newInstance()` does not run. A value whose run-time class differs from the
property's declared class is written with an `"@type"` entry and read back through it.
