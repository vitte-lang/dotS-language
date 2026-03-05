# ADR 0004: Runtime Scheduler, Memory Model and Cancellation

## Status
Accepted

## Decision
- Introduce a typed runtime result/error model.
- Propagate cancellation token through thread/channel/async/vm/jit safe points.
- Enforce strict thread lifecycle and channel invariants.
- Add baseline runtime metrics and p95 latency reporting.

## Consequences
- Better determinism and observability.
- Easier CI gates on timeouts/deadlocks/regressions.
