# Performance Changelog

## 2026-03-05
- Standardized benchmark module naming (`benchmark.*`).
- Added warmup + multi-run stats scaffolding.
- Added result persistence (JSONL/CSV/Prometheus) via `scripts/bench.sh`.
- Added compare current vs last and baseline hooks.
- Added quick/stress/smoke/nightly run modes.
