# Patterns

For structural guidance, use the skills rather than inventing patterns:

- **`nixos-patterns`** — flake layouts, multi-host splits, Home Manager layout, overlays,
  secrets placement, template-style examples.
- **`nixos-best-practices`** — idiomatic module/option practice.
- **`security-engagements`** — disposable engagement devShells, `.scrt/tools.toml`, vendoring.
- **`encryption`** — SOPS/age workflows.

## Repo conventions

- Host-split modules (`*.nix` vs `*-intel.nix` / `*-x11.nix` / `*-i3.nix`).
- Two overlays: `overlays/unstable-packages.nix` (exposes `pkgs.unstable.*`) and
  `overlays/additions.nix` (registers vendored `pkgs/*.nix`).
- Vendored derivations pinned by SRI hash with an update header.
- Security tools as `secBundles` in `flake.nix`, each with a `packages.sec-<cat>` build canary
  and composed per engagement via `scrt.lib.mkEngagement`.
