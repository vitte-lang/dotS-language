# DotS Stdlib

The stdlib is intentionally thin and layered over core/runtime primitives.

Current implemented slices:

- `stdlib/fs/*`
- `stdlib/io/*`
- `stdlib/text/*`

Design rule:

- stdlib modules should mostly wrap stable `core/*` contracts
- avoid duplicating heavy logic already present in CLI/runtime modules

Important dependencies:

- `stdlib/fs/*` depends on `core/fs`
- `stdlib/io/*` depends on `core/io`, `core/fs`, `core/process`
- `stdlib/text/*` depends on `core/str`

Recommended next slices:

- `stdlib/system/*`
- `stdlib/json/*`
- `stdlib/time/*`
