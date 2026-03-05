# Add a DotS benchmark in 5 minutes

1. Copier `bench/_template.dotS` vers `bench/<name>_bench.dotS`.
2. Définir:
   - `.module.benchmark.<name>.`
   - imports `.import.benchmark.config.` + `.import.benchmark.baseline.`
   - config top-level (`iterations/workers/...`)
3. Implémenter:
   - work unit
   - warmup
   - measured runs (`avg/median/p95/min/max/stddev/cv`)
4. Produire:
   - summary humain
   - summary JSON line (schema version)
5. Ajouter scénario dans `scripts/bench.sh` (`list-scenarios`).
6. Ajouter baseline dans `bench/baseline.json`.
