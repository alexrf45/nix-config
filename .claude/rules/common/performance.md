# Troubleshooting & efficiency

## Builds

- `nix flake check` surfaces an eval break; `nix log <drv>` for a failing build's output;
  `nixos-rebuild build` (not `switch`) to dry-run a host.
- `--override-input <name> path:<dir>` tests a local working tree without pushing.
- Heavy closures are opt-in by design — don't fold large tools into always-on modules.

## Context

- For large refactors, keep the diff surface small and lean on the skills instead of re-deriving
  facts already captured in `docs/` or memory.
