# Verifying changes

There is no unit-test suite — verification means **evaluating and building**.

- `nix flake check` — evaluate all flake outputs.
- `nixos-rebuild build --flake .#<host>` — dry-build a host before `switch` (no sudo needed).
- `nix build .#sec-all` (or `.#sec-<cat>`) — security devShell canary. **Run before landing a
  `nix flake update`**: `mkShell` is all-or-nothing, so one dead leaf breaks a whole bundle.
- `nix build .#scrt` — also runs shellcheck on the scrt scaffolder.
- Engagement/toolset changes: test against the working tree with
  `--override-input scrt path:$HOME/nix-config` before pushing (engagements pin the GitHub flake).

On a build failure, isolate with `nix log <drv>` and bisect bundles with `nix build .#sec-<cat>`.
