# DotS Benchmark Runbook

## Pre-requis
- Binaire `dots` disponible dans `PATH`
- Linux recommandé (pour `taskset`)
- `bash` et `sha256sum`

## Commandes exactes

### Lister
```bash
bash scripts/bench.sh list-bench
bash scripts/bench.sh list-scenarios json
```

### Quick (défaut)
```bash
DOTS_BENCH_MODE=quick bash scripts/bench.sh run-all
```

### Stress
```bash
DOTS_BENCH_MODE=stress DOTS_BENCH_RUNS=9 DOTS_BENCH_WARMUP=3 bash scripts/bench.sh run-all
```

### Smoke (ultra rapide)
```bash
DOTS_BENCH_MODE=smoke bash scripts/bench.sh run-all
```

### Nightly (ultra long)
```bash
DOTS_BENCH_MODE=nightly DOTS_BENCH_PARALLEL=1 bash scripts/bench.sh run-all
```

### Un bench ciblé
```bash
DOTS_BENCH_MODE=quick bash scripts/bench.sh run http
```

### Scenario pack
```bash
bash scripts/run_scenario.sh bench/scenarios/http_keepalive_a.env http
bash scripts/run_scenario.sh bench/scenarios/http_keepalive_b.env http
```

### Dry-run config
```bash
DOTS_BENCH_DRY_RUN=true DOTS_BENCH_MODE=stress bash scripts/bench.sh run json
```

## Overrides env
- `DOTS_BENCH_RUNS`, `DOTS_BENCH_WARMUP`, `DOTS_BENCH_SEED`
- `DOTS_BENCH_OUTPUT=json|human|both`
- `DOTS_BENCH_FAIL_ON_REGRESSION=true|false`
- `DOTS_BENCH_BASELINE_FILE=bench/baseline.json`
- `DOTS_BENCH_TAG`, `DOTS_BENCH_NOTES`
- `DOTS_BENCH_TIMEOUT_MS`, `DOTS_BENCH_COOLDOWN_MS`
- `DOTS_BENCH_CPU_AFFINITY=0-7`
- `DOTS_HTTP_URL=http://127.0.0.1:8080`

## Résultats
- JSONL: `bench/results/<bench>.jsonl`
- CSV: `bench/results/<bench>.csv`
- Prometheus: `bench/results/<bench>.prom`
- Dashboard: `bash scripts/bench.sh dashboard`

## Archiver / rotation
```bash
bash scripts/bench.sh rotate
```

## Stabilité machine
- Fixer l’affinité CPU: `DOTS_BENCH_CPU_AFFINITY=0-7`
- Fermer charges concurrentes
- Désactiver turbo/CPU scaling quand possible (governor `performance`)
- Exécuter nightly sur machine dédiée

## CI matrix
- PR: mode `quick` + budget gate + snapshot gate
- Nightly: mode `nightly` + budget gate strict
