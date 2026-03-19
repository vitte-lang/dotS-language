# DotS Modules

DotS currently supports three related module forms:

- `module.<name>` declares the current module
- `use.<package>` references an external package for consumption
- `import.<package>` references an external package explicitly

Vitte integration:

- default external package root: `../vitte/src/vitte/packages`
- override supported through `dots.json` with `vitte_packages_root`
- resolver prefers `mod.vit`
- resolver falls back to `info.vit`

Validation rules:

- package names must not contain `..`
- absolute paths are rejected
- missing packages produce semantic and LSP diagnostics

Current status:

- resolution works in check/build/run/graph/doc/search/lint/LSP
- runtime execution of imported package behavior is still shallow and preflight-oriented
