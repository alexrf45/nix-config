---
description: Update flake inputs and verify a host build
argument-hint: "[input]"
---

Update flake inputs safely.

1. `nix flake update` — or `nix flake lock --update-input $1` if a specific input is named.
2. `nix flake check` — evaluate all outputs.
3. `nixos-rebuild build --flake .#<host>` — confirm the host still builds (do both hosts).
4. Report `git diff flake.lock` (what moved) and any breakage.

Do **not** `switch` — leave that to the user. Work on a feature branch off `main`.
