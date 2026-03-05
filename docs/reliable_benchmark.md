# How to write a reliable DotS benchmark

## Goals
- Reproducible runs (`seed`, mode, config)
- Comparable outputs (human summary + JSON line)
- Regression detection against a baseline

## Required structure
1. Standard header: `bench`, `version`, `timestamp`, `run_id`, machine info
2. Explicit config at top (no hidden magic constants)
3. `setup`, `execution`, `cleanup` measured separately
4. Warmup runs before measured runs
5. Multiple measured runs and robust stats: `avg`, `median`, `p95`, `min`, `max`
6. Checksum/work proof to avoid dead-code style optimizations
7. Baseline delta and CI fail threshold

## Naming conventions
- Durations: `$setup_duration_ms`, `$exec_duration_ms`, `$execution_total_ms`, `$cleanup_duration_ms`
- Throughput:
  - generic: `$ops_per_ms`, `$ops_per_s`
  - http: `$req_per_ms`, `$req_per_s`
  - concurrency: `$msg_per_ms`, `$msg_per_s`

## Modes
- `DOTS_BENCH_MODE=quick`: lower cost local runs
- `DOTS_BENCH_MODE=stress`: high load profile runs
- `DOTS_BENCH_MODE=smoke`: ultra-fast sanity run
- `DOTS_BENCH_MODE=nightly`: long high-confidence run

## Runtime overrides
- `DOTS_BENCH_RUNS`, `DOTS_BENCH_WARMUP`, `DOTS_BENCH_SEED`
- `DOTS_BENCH_OUTPUT=json|human|both`
- `DOTS_BENCH_FAIL_ON_REGRESSION=true|false`
- `DOTS_BENCH_BASELINE_FILE`
- `DOTS_BENCH_TAG`, `DOTS_BENCH_NOTES`
- `DOTS_BENCH_TIMEOUT_MS`, `DOTS_BENCH_COOLDOWN_MS`
- `DOTS_BENCH_MACHINE_PROFILE`

## CI usage
- Run all benches: `dots run scripts/ci.vit -- all`
- Run one bench: `dots run scripts/ci.vit -- one http`
