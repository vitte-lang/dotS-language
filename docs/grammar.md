# DotS Grammar Notes

The canonical grammar is in `grammar/DotS.ebnf`.

## Key points
- Dot-separated instruction form: `.token.token.token.`
- Supports qualified identifiers such as `thread.pool.create`
- Supports typed operation arguments, e.g. `chan.create.$chan.int.$size`
- Strict booleans: `true` / `false` (not string equivalents)
- Strings support escapes: `\\`, `\"`, `\n`, `\r`, `\t`, `\uXXXX`

## Bench-oriented patterns
- Standardized module names: `.module.benchmark.<name>.`
- Operation form: `.qualified.identifier.<args>.`
- Env override form: `.sys.env.get."DOTS_BENCH_*".$var.`
- Summary JSON expected keys include:
  `schema_version`, `run_id`, `timestamp`, `machine_id`, `bench`, `scenario`,
  `avg_ms`, `p50_ms`, `p90_ms`, `p95_ms`, `p99_ms`, `stddev_ms`, `cv_pct`, `status`.
