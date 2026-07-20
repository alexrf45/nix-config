---
description: Verify a host build, then hand the switch to the user
argument-hint: "[host]"
---

Rebuild a host. `$1` is the target host (`horus` or `thoth`); if omitted, infer it from
`hostname` (default `thoth`).

1. Run `nixos-rebuild build --flake .#<host>` (no sudo) to verify the configuration builds.
2. If it fails, show the error and use `nix log <drv>` to isolate the failing derivation.
3. On success, tell the user to run `sudo nixos-rebuild switch --flake .#<host>` themselves —
   `switch` needs sudo (interactive) and should not be run non-interactively here.
