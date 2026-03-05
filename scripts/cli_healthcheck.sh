#!/usr/bin/env bash
set -euo pipefail

bash scripts/gen_parser_each_command_test.sh >/dev/null
bash scripts/gen_help_snapshots.sh >/dev/null
bash scripts/ci_cli_gate.sh
bash scripts/ci_registry_gate.sh
bash scripts/ci_json_flag_gate.sh
bash scripts/ci_cli_coverage_gate.sh
bash scripts/ci_no_shell_network_gate.sh
bash scripts/ci_json_contract_gate.sh
bash scripts/ci_real_protocol_gate.sh
bash scripts/ci_completion_up_to_date.sh
bash scripts/ci_completion_no_network_gate.sh
bash scripts/ci_geany_assets_gate.sh
bash scripts/ci_package_coverage_gate.sh
bash scripts/ci_lsp_stdout_gate.sh
bash scripts/ci_lsp_latency_gate.sh
bash scripts/ci_lsp_schema_gate.sh
bash scripts/ci_lsp_ttfo_gate.sh
bash scripts/ci_state_perf_budget.sh 5 300

# each command should have at least one test mentioning it
fail=0
for f in cmd/dots/*.vit; do
  b="$(basename "$f" .vit)"
  [[ "$b" =~ ^(main|registry|_command_template)$ ]] && continue
  if ! rg -n "\b${b}\b" tests/cli >/dev/null 2>&1; then
    echo "missing cli tests referencing command: $b"
    fail=1
  fi
done

[[ "$fail" -eq 0 ]] || exit 1

echo "cli healthcheck ok"
