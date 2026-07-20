# Troubleshooting & efficiency

## Builds

- A broken flake input usually surfaces as one dead leaf — bisect with `nix build .#sec-<cat>`.
- `nix log <drv>` for a failing build's output; `nixos-rebuild build` (not `switch`) to dry-run.
- `--override-input <name> path:<dir>` tests a local working tree without pushing.
- Heavy closures are opt-in by design (e.g. the `c2` bundle pulls Sliver's ~267MB server) — don't
  fold them into always-on modules.

## Context

- For large refactors, keep the diff surface small and lean on the skills instead of re-deriving
  facts already captured in `docs/` or memory.
