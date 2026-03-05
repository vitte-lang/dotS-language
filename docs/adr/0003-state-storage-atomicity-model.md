# ADR 0003: State Storage and Atomicity Model

## Status
Accepted

## Context
Registry backend state is written concurrently by install/update/publish flows and must remain recoverable after partial writes or process interruption.

## Decision
- JSONL state files use checksum sidecars.
- Writes are done through temp files then atomic rename/move wrapper.
- Global write lock guards concurrent state writers.
- Re-entrant lock is allowed for same `request_id`.
- Checksum mismatch triggers backup + recovery event.
- Strict mode (`DOTS_BACKEND_STRICT=1`) hardens validation and ID requirements.

## Consequences
- Better resilience against torn writes and race conditions.
- Slight overhead from checksum + lock + GC.
- Requires operational tooling (`registry doctor/events/reset --safe`) for diagnostics.
