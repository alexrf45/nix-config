# Coding style (Nix)

- **Format** with `alejandra` (`nix fmt`) before committing.
- **Small, focused modules.** Split by host variant (`hardware.nix` vs `hardware-intel.nix`,
  `desktop.nix` vs `desktop-x11.nix`) and by domain; a shared module imported by both hosts
  belongs in `modules/`.
- **Declarative & immutable** — no imperative/stateful hacks. Overlays are declared in
  `hosts/<host>/default.nix`, never inside `home.nix` (silently ignored under `useGlobalPkgs`).
- **Match the surrounding style** — comment density, the `with pkgs; [ … ]` list idiom, attr
  naming (hyphens are valid identifiers: `netcat-gnu`, `recon-ng`).
- **No hardcoded secrets** or machine-specific paths outside the relevant host module.
- **Prefer nixpkgs**; vendor (`pkgs/*.nix` + `overlays/additions.nix`) only when a tool isn't packaged.
- Comment the *why* for non-obvious pins, overrides, and boot-critical settings (VMD, PRIME).
