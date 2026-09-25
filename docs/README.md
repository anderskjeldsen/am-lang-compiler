# AmLang documentation

The [main README](../README.md) describes the current v0.13.0 compiler. Start with [getting started](18-getting-started.md), [compiler usage](16-compiler-usage.md), and the [v0.13.0 release notes](../release-notes/RELEASE_NOTES_v0.13.0.md).

## Language reference

- [Language overview](01-language-overview.md)
- [Syntax and grammar](02-syntax-grammar.md)
- [Keywords](03-keywords.md)
- [Type system](04-type-system.md)
- [Variables and constants](05-variables-constants.md)
- [Classes and objects](06-classes-objects.md)
- [Functions](10-functions.md)
- [Threading and concurrency](11-threading.md)
- [Native integration](12-native-integration.md)

## Projects and tools

- [Project structure](15-project-structure.md)
- [Compiler usage](16-compiler-usage.md)
- [Getting started](18-getting-started.md)
- [Examples](19-examples.md)
- [Runnable example projects](../examples/)

## Release compatibility

Use `.aml` source files. In v0.13.0, bare object types are non-null and nullable objects use `?`; the legacy-nullability package flag and class directive are rejected. Test builds use `test-builds/`. Older release notes describe historical behavior; use the current [upgrade guide](../README.md#upgrading-to-v0130) when migrating.
