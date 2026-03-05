# ADR 0006: Runtime Determinism Policy

## Decision
Determinism is controlled by `DOTS_RUNTIME_SEED`.
All runtime jitter/backoff randomness uses `runtime/common/prng.vit`.

Trace replay is available in `.dots/runtime_trace.jsonl`.
