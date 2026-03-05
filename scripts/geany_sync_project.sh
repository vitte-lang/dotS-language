#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/dotS-language.geany"

cat > "$OUT" <<GEANY
[project]
name=dotS-language
base_path=$ROOT
description=DotS language workspace profile
file_patterns=*.dotS;*.vit;*.md;*.sh

[long line marker]
long_line_behaviour=1
long_line_column=100

[indentation]
width=4
type=1
hard_tabs=0
detect_from_indent=true
detect_from_content=true

[build-menu]
FT_00_LB=Lint
FT_00_CM=dots lint --format json "%f"
FT_00_WD=%p
FT_01_LB=Fmt
FT_01_CM=dots fmt --write "%f"
FT_01_WD=%p
FT_02_LB=Run
FT_02_CM=dots run "%f"
FT_02_WD=%p
FT_03_LB=Check
FT_03_CM=dots check "%f"
FT_03_WD=%p

EX_00_LB=Generate completions
EX_00_CM=bash scripts/gen_completion_from_registry.sh
EX_00_WD=%p
EX_01_LB=Completion gate
EX_01_CM=bash scripts/ci_completion_up_to_date.sh
EX_01_WD=%p
EX_02_LB=Run selection via eval
EX_02_CM=dots eval --expr "%s"
EX_02_WD=%p
EX_03_LB=Open bench dashboard
EX_03_CM=bash scripts/bench.sh dashboard
EX_03_WD=%p
EX_04_LB=Run parser test generation
EX_04_CM=bash scripts/gen_parser_each_command_test.sh
EX_04_WD=%p
EX_05_LB=Run completion gates
EX_05_CM=bash -lc 'bash scripts/ci_completion_up_to_date.sh && bash scripts/ci_completion_no_network_gate.sh'
EX_05_WD=%p
EX_06_LB=Run real protocol gate
EX_06_CM=bash scripts/ci_real_protocol_gate.sh
EX_06_WD=%p
EX_07_LB=Run startup bench budget
EX_07_CM=bash scripts/cli_startup_bench.sh 20 120
EX_07_WD=%p
EX_08_LB=Run fake registry e2e subset
EX_08_CM=bash -lc 'dots test --filter e2e_fake_registry'
EX_08_WD=%p
EX_09_LB=Bench quick
EX_09_CM=DOTS_BENCH_MODE=quick bash scripts/bench.sh run-all
EX_09_WD=%p
EX_10_LB=Bench stress
EX_10_CM=DOTS_BENCH_MODE=stress bash scripts/bench.sh run-all
EX_10_WD=%p
EX_11_LB=CLI healthcheck
EX_11_CM=bash scripts/cli_healthcheck.sh
EX_11_WD=%p
GEANY

echo "synced $OUT"
