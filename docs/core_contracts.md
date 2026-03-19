# Core Contracts

This document defines the minimum stable contract expected from three foundational modules used across DotS:

- `core/fs`
- `core/io`
- `core/process`

These contracts matter because CLI commands, LSP handlers, runtime helpers, stdlib wrappers and package backends all depend on them.

## `core/fs`

Expected capabilities:

- `exists(path)`
- `is_file(path)`
- `read_file(path)`
- `write_file(path, content)`
- `append_file(path, content)`
- `read_dir(path)`
- `mkdir_p(path)`
- `remove(path)`
- `remove_all(path)`
- `mtime_ms(path)`
- `base_name(path)`
- `dir_name(path)`

Behavioral rules:

- callers stay responsible for explicit missing-file handling
- direct local operations are preferred over shell delegation
- text-oriented behavior should remain deterministic

## `core/io`

Expected capabilities:

- `print(message)`
- `read_stdin_all()`

Behavioral rules:

- output must remain safe for human and JSON-oriented CLI callers
- stdin capture should be total and simple unless a caller builds interactive behavior explicitly

## `core/process`

Expected capabilities:

- `args()`
- `env(name)`
- `set_env(name, value)`
- `cwd()`
- `chdir(path)`
- `exec(bin, argv)`
- signal/cancellation helpers when available

Behavioral rules:

- validate inputs before spawning child processes
- keep env and cwd handling explicit
- prefer core implementations before falling back to shell commands

## Stability Guidance

All stdlib wrappers should prefer these core contracts instead of re-implementing filesystem, output or process logic ad hoc.
