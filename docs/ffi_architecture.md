# FFI Architecture

## Objectifs

- Contrat unique d’erreur et de résultat.
- Sécurité des chemins/arguments.
- Exécution reproductible (timeouts, retry policy, circuit-breaker).
- Observabilité (events JSONL + métriques latence p50/p95/p99).

## Modules

- `ffi/c/ffi.vit`
  - `FFIError`, `FFIResult`, `FFISignature`, `FFIHandle`, `FFIPolicy`.
  - `ffi_load_library`, `ffi_resolve_symbol`, `ffi_call`, `ffi_unload`.
  - `ffi_sequence_load_resolve_call_unload`.
  - Cache handles refcounté (`.dots/state/ffi/handles.v2.jsonl`).
  - Lock cross-process avec recovery stale lock.
  - Circuit-breaker global par symbol.
  - Stats: `load_ms`, `resolve_ms`, `call_ms`, `fail_total`.
  - Latences call: p50/p95/p99.

- `ffi/c/symbol.vit`
  - Helpers de parsing de signature (`returns`, `args_csv`, `abi`).
  - Validation stricte des types canoniques.

- `ffi/c/call.vit`
  - Parsing args + invoke standard load/resolve/call/unload.

- `ffi/cpp/binding.vit`, `ffi/cpp/wrapper.vit`
  - Binding C++ + wrapper ownership.

- `ffi/python/py_bridge.vit`
  - Init runtime Python + policy GIL.

- `ffi/wasm/wasm_loader.vit`, `ffi/wasm/wasm_runtime.vit`
  - Validation module wasm, exports, exécution avec limites.

## Contrat JSON

- `schema_version`: `1.1.0`
- `run_id`
- `request_id`
- `status`
- `error_type` / `error_message` en cas d’échec

## Sécurité

- Blocage traversal (`../`) via `secure_join`.
- Allowlist extensions: `.so`, `.dylib`, `.dll`, `.wasm`.
- Vérification existence + lisibilité avant load.
- Redaction secrets dans logs/events: `token=`, `password=`, `secret=`.
- Validation stricte type/arity.
- Aucun cast implicite dangereux.

## État & événements

- `.dots/state/ffi/handles.v2.jsonl`
- `.dots/state/ffi/stats.v2.jsonl`
- `.dots/state/ffi/latency.v2.jsonl`
- `.dots/state/ffi/cb.v2.jsonl`
- `.dots/state/ffi/events.jsonl`

Chaque fichier d’état est accompagné d’un checksum simple (`*.checksum`).

## Variables d’environnement clés

- `DOTS_FFI_STRICT=1`
- `DOTS_FFI_EXPECT_ARCH`, `DOTS_FFI_EXPECT_ENDIAN`
- `DOTS_FFI_RETRIES`, `DOTS_FFI_RETRY_BUDGET`
- `DOTS_FFI_RETRY_BASE_DELAY_MS`, `DOTS_FFI_RETRY_JITTER_MS`
- `DOTS_FFI_JITTER_POLICY=none|equal|full`
- `DOTS_FFI_CB_THRESHOLD`, `DOTS_FFI_CB_COOLDOWN_MS`
- `DOTS_FFI_TIMEOUT_MS`
- `DOTS_BACKEND_SEED`

