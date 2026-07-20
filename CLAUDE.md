# NixOS Config

NixOS flake for two personal laptops. Stable `nixos-26.05` + a `nixos-unstable` overlay for
select packages; Home Manager as an integrated module (`useGlobalPkgs`); secrets via SOPS + age.

## Hosts

| Host    | Machine                | GPU                            | Desktop        | Role                           |
|---------|------------------------|--------------------------------|----------------|--------------------------------|
| `horus` | Acer Nitro 5           | AMD iGPU + NVIDIA (PRIME)      | Sway (Wayland) | primary workstation            |
| `thoth` | Intel i5-1155G7        | Intel Iris Xe                  | i3 (X11)       | security-research daily driver |

Build/switch: `sudo nixos-rebuild switch --flake .#<host>` (see the `/rebuild` command).
Hardware/storage/boot detail lives in `docs/hardware.md`; first-time setup in `docs/bootstrap.md`.

## Structure

```
hosts/<host>/          host entry + hardware-configuration.nix
modules/nixos/         system modules (hardware, networking, security, desktop, audio, …)
modules/home-manager/  HM modules (shell, terminal, editor, tmux, git, dev-tools, security, …)
home-manager/<host>/   per-user HM entry point
overlays/              unstable-packages + additions (vendored pkgs) overlays
pkgs/                  vendored derivations (linpeas, winpeas, …, sliver) + the scrt scaffolder
templates/             flake templates (engagement, python, mkdocs)
secrets/               SOPS-encrypted .yaml (age)
```

Shared modules split into host variants where hardware/desktop differ — e.g. `hardware.nix` vs
`hardware-intel.nix`, `desktop.nix` (Sway) vs `desktop-x11.nix` (i3), HM `desktop.nix` vs `desktop-i3.nix`.

## Key design decisions

- nixpkgs `nixos-26.05` stable + `nixos-unstable` overlay for select packages.
- Home Manager integrated (`useGlobalPkgs = true`); overlays declared in `hosts/<host>/default.nix`, not in home.nix.
- horus GPU: NVIDIA PRIME offload (AMD drives the display, NVIDIA on demand).
- Sound: PipeWire + WirePlumber; Display: GDM + Sway (horus) / i3 (thoth).
- Secrets: SOPS + age (key at `~/.config/sops/age/keys.txt`, never in the repo → `/run/secrets/` after activation).
- Security tooling lives in disposable engagement devShells, **not** the system profile.

## Working in this repo

- **Git:** feature branch off `main`, PR into `main` — never commit to `main` directly (`.claude/rules/common/git-workflow.md`).
- **Verify by building:** `nix flake check`, `nixos-rebuild build --flake .#<host>`, and `nix build .#sec-all` before landing a flake update (`.claude/rules/common/testing.md`, `/flake-update`).
- **Format** Nix with `alejandra` (`nix fmt`).
- **Security engagements / devShells / vendoring:** the `security-engagements` skill + `docs/engagements.md`.

Reference: <https://github.com/alexrf45/h0me>, <https://github.com/alexrf45/dotfiles> (mirrored in `dotfiles/`).
