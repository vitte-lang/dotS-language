# Registry Backend Contract

## State Files

Location:
- default: `.dots/state/<workspace_hash>/`
- override: `DOTS_STATE_DIR`

Primary files:
- `state.v2.jsonl`
- `cb.v2.jsonl`
- `stats.v2.jsonl`
- `latency.v2.jsonl`
- `events.v2.jsonl`
- `published.v2.jsonl`
- `installed.v2.jsonl`

Each line is JSONL with:
- `schema_version` (current `1.1.0`)
- `v` (storage generation, current `2`)

## Integrity

- Data file checksum sidecar: `<file>.checksum`
- Preferred digest: `sha256:<hex>`
- Legacy fallback accepted for migration.
- On mismatch:
  - backup `*.corrupt.<ts>`
  - targeted recovery/rebootstrap
  - event `STATE_RECOVERED`

## Concurrency

- Global write lock: `state_write.lock.d`
- Mutation lock: `mutation.lock.d`
- Half-open probe lock: `cb_probe.lock.d`

## Strict Mode

Enable with `DOTS_BACKEND_STRICT=1`.

Effects:
- stricter env/schema/checksum handling
- requires `DOTS_RUN_ID` and `DOTS_REQUEST_ID` for strict request paths

## Retry/Policy

Supported:
- `DOTS_RETRY_ON` with category selectors:
  - `connect:*`
  - `application:*`
  - `application:E_TIMEOUT`
- `DOTS_JITTER_POLICY=none|equal|full`
- granular timeouts:
  - `DOTS_CONNECT_TIMEOUT_MS`
  - `DOTS_REQUEST_TIMEOUT_MS`
  - `DOTS_OVERALL_TIMEOUT_MS`

## Events

File: `events.v2.jsonl`

Fields:
- `run_id`, `request_id`
- `kind`, `severity`, `component`
- redacted `message`

Rotation controls:
- `DOTS_EVENTS_MAX_BYTES`
- `DOTS_EVENTS_MAX_AGE_MS`

## Operator Commands

- `dots registry status --json|--prom`
- `dots registry doctor [--json]`
- `dots registry events --lines <n> [--follow]`
- `dots registry reset [--safe]`

## Incident Notes

### checksum mismatch storm
- Symptom: repeated `STATE_RECOVERED` events.
- Actions: run `dots registry doctor --json`, inspect `*.corrupt.*`, then `dots registry reset --safe`.

### write lock contention
- Symptom: rising `state_write_lock_timeout_total` / `lock_contention_total`.
- Actions: increase timeout/backoff (`--timeout-ms`, `DOTS_LOCK_BACKOFF_CAP_MS`), avoid concurrent mutations.

### CB stuck half-open
- Symptom: `cb_state=half_open` with `cb_half_open_reject_total` increasing.
- Actions: inspect events, run `dots registry reset --safe`, review endpoint health and cooldown settings.
