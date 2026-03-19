# DotS Language Spec

DotS is a dotted, script-oriented language.

Core statement forms:

- `module.<name>`
- `use.<package>`
- `import.<package>`
- `fn.<name>.$arg1.$arg2`
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
