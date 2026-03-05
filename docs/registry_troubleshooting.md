# Registry Troubleshooting

## Circuit breaker open
- Check: `dots registry status --json`
- Reset: `dots registry reset --json`

## Offline failures
- Error type: `OFFLINE`
- Cause: `--offline` enabled while network op required

## Package not found
- Error type: `PACKAGE_NOT_FOUND`
- Add package for fake mode:
```bash
scripts/fake_registry.sh add-pkg .dots/fake_registry mypkg 1.0.0
```

## Signature/checksum failure
- Error type: `SIGNATURE_INVALID`
- Re-init fake registry or regenerate package entry format.
