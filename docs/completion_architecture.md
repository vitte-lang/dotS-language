# Completion Architecture

## Source of truth
- Unique source: `cmd/dots/registry.vit`
- Generator: `scripts/gen_completion_from_registry.sh`
- Generated files:
  - `completions/dots.bash`
  - `completions/_dots`
  - `completions/dots.fish`
  - `completions/registry.json`

## Contracts
- `completion_schema_version` embedded in generated outputs.
- No network access in completion path.
- Completion generation must be idempotent.

## CI gates
- `scripts/ci_completion_up_to_date.sh`
  - Regenerates and fails if `completions/*` differs.
- `scripts/ci_completion_no_network_gate.sh`
  - Fails on network calls in completion scripts.

## Local workflow
```bash
bash scripts/gen_completion_from_registry.sh
bash scripts/ci_completion_up_to_date.sh
bash scripts/ci_completion_no_network_gate.sh
```

## Add a command safely
1. Update `cmd/dots/registry.vit` (`CommandDef` + options).
2. Regenerate completions.
3. Update snapshots:
   - `tests/snapshots/completions/*.snapshot`
4. Run completion gates.

