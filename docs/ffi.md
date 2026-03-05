# FFI Overview

Ce dépôt fournit un socle FFI structuré dans `ffi/*`:

- `ffi/c/ffi.vit`: API publique, erreurs typées, résultat commun, lock/cache, events, métriques, doctor/status.
- `ffi/c/symbol.vit`: résolution symbole + validation signature.
- `ffi/c/call.vit`: marshalling + invocation + timeout/retry.
- `ffi/cpp/*`: conventions C++ (binding + wrapper ownership).
- `ffi/python/py_bridge.vit`: pont Python (runtime + politique GIL).
- `ffi/wasm/*`: chargement/exécution wasm (exports, limites mémoire/fuel, interruption).

Contrat de base:

1. `ffi_load_library`
2. `ffi_resolve_symbol`
3. `ffi_call`
4. `ffi_unload`

Codes d’erreur standard:

- `FFI_ERROR`
- `SYMBOL_NOT_FOUND`
- `ABI_MISMATCH`
- `CALL_FAILED`
- `TIMEOUT`

Toutes les réponses JSON exposent `schema_version`, `run_id`, `request_id`.

Docs détaillées:

- `docs/ffi_architecture.md`
- `docs/ffi_runbook.md`
