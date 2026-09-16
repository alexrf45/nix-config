# NixOS Config

NixOS flake for personal laptops — `thoth` is the only active host; `horus` is retired (2026-09).
Stable `nixos-26.05` + a `nixos-unstable` overlay for select packages;
Home Manager as an integrated module (`useGlobalPkgs`); secrets via SOPS + age.

## Hosts

| Host    | Machine                | GPU                            | Desktop        | Role                           | Status  |
|---------|------------------------|--------------------------------|----------------|--------------------------------|---------|
| `thoth` | Intel i5-1155G7        | Intel Iris Xe                  | i3 (X11)       | writing / research / dev daily driver | active  |
| `horus` | Acer Nitro 5           | AMD iGPU + NVIDIA (PRIME)      | i3 (X11)       | former workstation             | retired |

Build/switch: `sudo nixos-rebuild switch --flake .#thoth` (see the `/rebuild` command).

> **horus is retired (2026-09).** Its `nixosConfigurations.horus` flake output was removed, but
> its config (`hosts/horus/`, `home-manager/horus/`, and horus-only modules like `hardware.nix`
> and `ollama.nix`) is kept in the repo, unmaintained. To revive it, re-add the output in
> `flake.nix` (a copy of the `thoth` block pointing at `./hosts/horus`), expect to fix eval
> drift, and set the real PRIME bus IDs first (`docs/bootstrap.md`).

Hardware/storage/boot detail lives in `docs/hardware.md`; first-time setup in `docs/bootstrap.md`.

## Structure

```
hosts/<host>/          host entry + hardware-configuration.nix
modules/nixos/         system modules (hardware, networking, security, desktop, audio, …)
modules/home-manager/  HM modules (shell, terminal, editor, tmux, git, dev-tools, …)
home-manager/<host>/   per-user HM entry point
overlays/              unstable-packages + additions (vendored pkgs) overlays
pkgs/                  vendored derivations (1Password CLI/GUI beta)
templates/             flake templates (python, mkdocs)
secrets/               SOPS-encrypted .yaml (age)
```

Shared modules split into host variants where hardware differs — e.g. `hardware.nix` vs
`hardware-intel.nix`. Both hosts were aligned on i3 (X11) via `desktop-x11.nix` + HM `desktop-i3.nix`; the
Sway modules (`modules/nixos/desktop.nix`, HM `desktop.nix`) are retained but unused (Wayland fallback).

## Key design decisions

- nixpkgs `nixos-26.05` stable + `nixos-unstable` overlay for select packages.
- Home Manager integrated (`useGlobalPkgs = true`); overlays declared in `hosts/<host>/default.nix`, not in home.nix.
- horus GPU (retired host): NVIDIA PRIME offload (AMD drives the display, NVIDIA on demand).
- Sound: PipeWire + WirePlumber; Display: i3 (X11) (horus was aligned to thoth before retirement). Sway modules kept but unused.
- Secrets: SOPS + age (key at `~/.config/sops/age/keys.txt`, never in the repo → `/run/secrets/` after activation).

> **Note:** the security-research tooling (CTF/pentest devShells, `secBundles`, the `scrt`
> engagement scaffolder, vendored offensive tools) was retired in 2026-07 — day-to-day is now
> writing / research / dev. See `docs/security-tooling-archived.md` to revive it.

## Working in this repo

- **Git:** feature branch off `main`, PR into `main` — never commit to `main` directly (`.claude/rules/common/git-workflow.md`).
- **Verify by building:** `nix flake check` and `nixos-rebuild build --flake .#<host>` (`thoth`, the only host) before landing a flake update (`.claude/rules/common/testing.md`, `/flake-update`).
- **Format** Nix with `alejandra` (`nix fmt`).

Reference: <https://github.com/alexrf45/h0me>, <https://github.com/alexrf45/dotfiles> (mirrored in `dotfiles/`).
