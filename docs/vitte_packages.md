# Vitte Package Integration

DotS can now resolve package sources from the Vitte repository package tree.

Default root:

```text
../vitte/src/vitte/packages
```

Override in `dots.json`:

```json
{
  "name": "my-dots-project",
  "version": "0.1.0",
  "license": "GPL-3.0-or-later",
  "vitte_packages_root": "../vitte/src/vitte/packages"
}
```

Available integration modules:

- `modules/loader/resolver.vit`
- `modules/loader/importer.vit`
- `modules/loader/loader.vit`

Current behavior:

- resolves `<root>/<package>/mod.vit` first
- falls back to `<root>/<package>/info.vit`
- blocks unsafe names containing `..` or absolute paths
- supports package discovery via directory scan
