# Verifying changes

There is no unit-test suite — verification means **evaluating and building**.

- `nix flake check` — evaluate all flake outputs. **Run before landing a `nix flake update`.**
- `nixos-rebuild build --flake .#<host>` — dry-build a host before `switch` (no sudo needed).
  Build `thoth` after touching shared modules or overlays. `horus` is **retired** (2026-09) — its
  config is kept but not required to build.

On a build failure, isolate with `nix log <drv>`.
