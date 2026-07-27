# Verifying changes

There is no unit-test suite — verification means **evaluating and building**.

- `nix flake check` — evaluate all flake outputs. **Run before landing a `nix flake update`.**
- `nixos-rebuild build --flake .#<host>` — dry-build a host before `switch` (no sudo needed).
  Build **both** hosts (`thoth` and `horus`) after touching shared modules or overlays.

On a build failure, isolate with `nix log <drv>`.
