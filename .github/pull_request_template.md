## Summary

## Perf Checklist (required for runtime/parser/vm changes)
- [ ] I ran `DOTS_BENCH_MODE=quick bash scripts/bench.sh run-all`
- [ ] I checked `bench/results/dashboard.md`
- [ ] No regression/unstable status in results
- [ ] If perf changed intentionally, I updated `bench/baseline.json`
- [ ] I added/updated benchmarks or tests when needed
