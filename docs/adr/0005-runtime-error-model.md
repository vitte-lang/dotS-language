# ADR 0005: Runtime Error Model

## Decision
Use a centralized runtime error catalog in `runtime/errors.vit` with:
- stable error codes
- retryability mapping
- exit code mapping

All runtime boundaries return `RuntimeResult` and redact messages.
