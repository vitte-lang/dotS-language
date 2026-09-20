# DotS Syntax Reference

This page summarizes the canonical surface syntax used across the repository.

## Canonical form

- Statements are line-oriented.
- Canonical statements do not use leading or trailing dots.
- Dot separators are significant inside a statement.

## Statement families

- `module.<name>` declares the current module.
- `use.<package>` references a dependency for use.
- `import.<package>` references a dependency explicitly.
- `fn.<name>.$arg1.$arg2` declares a function-like block.
- `set.$var.<expr>`, `let.$var.<expr>`, `const.$var.<expr>` bind values.
- `call.<name>.<arg1>.<arg2>` invokes a qualified operation.
- `ret` and `ret.<expr>` return from the current block.
- `if.<expr>`, `elif.<expr>`, `else`, `loop.<expr>`, `while.<expr>`, `for.$var.<expr>` control flow.
- `break`, `continue`, `try`, `catch`, `throw.<expr>` manage flow and errors.

## Token categories

- identifiers: `thread`, `json`, `runtime_status`
- qualified identifiers: `thread.pool.create`
- variables: `$name`, `$count`, `$summary_json`
- strings: `"dotS sample"`
- numbers: `0`, `42`, `1000`
- booleans: `true`, `false`
- comments: `# comment text`

## Valid examples

```dotS
module.demo.syntax
use.thread
set.$workers.4
thread.pool.create.$pool.$workers
call.thread.pool.start
ret.true
```

```dotS
module.demo.json
set.$enabled.true
set.$name."dotS sample"
json.set.$obj."enabled".$enabled
json.set.$obj."name".$name
chan.create.$chan.int.64
```

## Invalid examples

```dotS
module..http
```
Invalid: empty module segment.

```dotS
set.iterations.1000
```
Invalid: variable must start with `$`.

```dotS
chan.create.$chan.integer.$n
```
Invalid: `integer` is not a valid type identifier in the current language subset.

## Cross references

- Grammar notes: [`docs/grammar.md`](grammar.md)
- Language spec: [`docs/language_spec.md`](language_spec.md)
- Editor setup: [`docs/editor_setup.md`](editor_setup.md)
