# AmLang Syntax Highlighting (VS Code)

Provides TextMate-based syntax highlighting for the Am language.

## Features
- Namespaces, imports (`import Am.IO.Networking`)
- Class and function declarations (`class`, `fun`)
- Variables (`var`), `static`
- Primitive types (Bool, Int, String, ...)
- Strings, numbers, operators
- Line (`//`) and block (`/* ... */`) comments

## Install (Dev)
1. Open this folder in VS Code.
2. Press **F5** to start an Extension Development Host.
3. Open a `.am` file to see highlighting.

## Manual Install
- Install `vsce` (`npm i -g @vscode/vsce`) and run `vsce package`, then install the generated `.vsix` in VS Code.
- Or copy the folder into your extensions dir and reload window.

## File Associations
Add to your settings if needed:
```json
"files.associations": { "*.aml": "amlang" }
```

## Example
```amlang
namespace Am.Examples {
    class CoreStartup {
        import Am.Lang
        import Am.Lang.Diagnostics
        static var boolValue: Bool = true
        static fun main() { /* ... */ }
    }
}
```
