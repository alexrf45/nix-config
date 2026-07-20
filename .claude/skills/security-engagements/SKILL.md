---
name: security-engagements
description: Disposable per-engagement security devShells in this repo — scaffolding with scrt, the .scrt/tools.toml category model, and vendoring tools not in nixpkgs. Use when working on CTF/pentest engagement directories, the secBundles in flake.nix, the engagement template, or adding/bumping security tools.
---

# Security engagements & devShells

End-user guide: `docs/engagements.md`. This skill is the working model for **changing** the system.

## Model

- The **engagement directory** is the unit of disposability. `scrt new <name> [rhost] [lhost]`
  scaffolds `$SCRT_ROOT/<name>` (default `/home/data/engagements`) from `templates/engagement`;
  `scrt ls` lists, `scrt fix <name>` repairs older ones. `scrt` = `pkgs/scrt.sh` wrapped by
  `writeShellApplication` in `flake.nix`.
- Each dir composes **one** shell from `.scrt/tools.toml` via `scrt.lib.mkEngagement` (a flake
  output), read with `builtins.fromTOML`: `categories` (base always included) + `extra`
  (pkgs-sec attrs) + `exclude` (by `lib.getName`). Empty/missing categories is a hard eval error.
- Categories are `secBundles` in `flake.nix`: `web ad forensics pwn osint cloud wireless mobile c2`.
  Each is also a `packages.sec-<cat>` buildEnv (canary) and a parent `nix develop .#<cat>` shell.
  Shells share `mkSecShellFromPackages` (exports `$RUBEUS/$CERTIFY/$WINPEAS/$NISHANG_DIR`,
  sources `.scrt/env`).

## Rules that bite

- **Flakes only see git-tracked files.** `.scrt/tools.toml` and `flake.nix` must be committed/
  staged; `scrt new` runs `git add -A`, and edits to an already-tracked file are live (dirty
  tree) but a new untracked file is invisible to eval/build.
- **`mkShell` is all-or-nothing** — one dead leaf kills the whole shell. Run `nix build .#sec-<cat>`
  after any bundle change. Watch for abandoned Python tools importing `pkg_resources` (wfuzz,
  kube-hunter) — dead on modern Python, they take the category down. `apksigner` (mobile) needs
  `config.android_sdk.accept_license = true` in the `pkgs-sec` import.
- **Engagements pin `github:alexrf45/nix-config`.** Test changes locally with
  `--override-input scrt path:$HOME/nix-config` (and `SCRT_FLAKE=path:$HOME/nix-config` for
  `scrt new`); changes must be pushed to take effect for real engagements.

## Adding a tool

- **In nixpkgs-unstable:** add its attr to the relevant list in `secBundles`, or drop it into a
  `tools.toml` `extra = [...]` for a one-off. Verify existence first (`nix eval` / `nix search`).
- **Not in nixpkgs:** vendor `pkgs/<tool>.nix` (pin the release asset with an SRI hash; follow the
  update header in each file — see `pkgs/sliver.nix` for a patched binary via `autoPatchelfHook`,
  `pkgs/linpeas.nix` for a script) and register it in `overlays/additions.nix`.
- Always finish with `nix build .#sec-<cat>` (and `.#sec-all` before a flake update).

## Deferred / follow-ups

- PoshC2 (Python; not in nixpkgs) is not yet vendored for the `c2` bundle.
- `templates/engagement/flake.nix` + `SCRT_FLAKE` pin a branch during testing — keep them in sync.
