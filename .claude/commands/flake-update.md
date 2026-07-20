---
description: Update flake inputs, run the security canary, verify a host build
argument-hint: "[input]"
---

Update flake inputs safely.

1. `nix flake update` — or `nix flake lock --update-input $1` if a specific input is named.
2. `nix build .#sec-all` — catch any security-bundle leaf broken by the update (the wfuzz/
   kube-hunter failure class). If a category breaks, bisect with `nix build .#sec-<cat>`.
3. `nixos-rebuild build --flake .#<host>` — confirm the host still builds.
4. Report `git diff flake.lock` (what moved) and any breakage.

Do **not** `switch` — leave that to the user. Work on a feature branch off `main`.
