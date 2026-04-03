# DotS Stdlib

The stdlib is a batteries-included layer over stable `core/*` contracts.
It keeps runtime-facing APIs simple, explicit, and deterministic.

## Conventions

- Prefer pure helpers returning plain values when failure is impossible.
- Use `*_or` for fallback/default behavior.
- Use `*_result` for validated/error-aware behavior via `stdlib/system/result`.
- Keep heavy parsing/network/runtime logic in `core/*` and expose thin wrappers here.

## Implemented Modules

- `stdlib/text/*`: string search/split/replace, line helpers, padding, formatting.
- `stdlib/collections/*`: list/set/map/queue/graph containers and utility operations.
- `stdlib/fs/*`: read/write/copy/remove/stat/path/walk with safe variants.
- `stdlib/json/*`: JSON shape checks and typed field extraction helpers.
- `stdlib/time/*`: timestamps, duration parse/format, elapsed/remaining helpers.
- `stdlib/math/*`: aggregates, stats, matrix helpers, random helpers.
- `stdlib/net/http/*`: request/response/router/middleware/server/client policy helpers.
- `stdlib/io/*`: console/input/print/logger/terminal wrappers.
- `stdlib/system/*`: environment/process/os/result primitives.

## Dependency Rules

- `stdlib/fs/*` -> `core/fs`
- `stdlib/io/*` -> `core/io`, `core/fs`, `core/process`, `core/time`
- `stdlib/text/*` -> `core/str`
- `stdlib/time/*` -> `core/time`, `core/str`
- `stdlib/math/random` -> `runtime/common/prng`

## API Stability Notes

- Keep function names action-first and lowercase (`read`, `set`, `parse_*`).
- Prefer additive evolution (new proc) over signature breaks.
- If a proc can fail with actionable diagnostics, add a sibling `*_result`.
