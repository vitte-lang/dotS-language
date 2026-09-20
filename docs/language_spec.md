# DotS Language Spec

DotS is a dotted, script-oriented language.
Canonical statements are line-oriented and do not use leading or trailing dots.

Core statement forms:

- `module.<name>` for the current module
- `use.<package>` for package consumption
- `import.<package>` for explicit package references
- `fn.<name>.$arg1.$arg2` for function declarations
- `set.$var.<expr>`
- `let.$var.<expr>`
- `const.$var.<expr>`
- `call.<name>.<arg1>.<arg2>`
- `ret`
- `ret.<expr>`
- `if.<expr>`
- `elif.<expr>`
- `else`
- `loop.<expr>`
- `while.<expr>`
- `for.$var.<expr>`
- `break`
- `continue`
- `try`
- `catch`
- `throw.<expr>`

Values:

- identifiers
- variables like `$name`
- strings
- numbers
- booleans `true` and `false`
- nested `call.*`

Parsing model:

- statements are line-oriented
- dot separators are significant
- parser produces a simple AST used by semantic checks, CLI tools and LSP

Semantic model:

- top-level declarations build a symbol table
- undeclared calls are reported as semantic diagnostics
- `use/import` are validated against Vitte package resolution when enabled
