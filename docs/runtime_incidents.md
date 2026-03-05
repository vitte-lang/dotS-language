# Runtime Incident Runbook

## Deadlock storm
1. Run `dots runtime status --json`.
2. Inspect `deadlock_watchdog_trigger_total` and lock contention metrics.
3. Reduce concurrency, increase timeout, review mutex ownership.

## Timeout flood
1. Check global timeout config `DOTS_RUNTIME_TIMEOUT_MS`.
2. Inspect `RUNTIME_TIMEOUT` and `channel_wait_*` counters.
3. Increase queue capacity or switch policy `drop|block`.

## OOM
1. Inspect allocator quotas and `alloc_fail_total`.
2. Increase heap hard limit or reduce object creation rate.
3. Verify GC cycle throughput.

## GC thrash
1. Inspect `gc_pause_ms`, `gc_mark_ms`, `gc_sweep_ms`.
2. Check `gc_live_bytes` trend.
3. Tune heap soft/hard quotas and workload batching.
