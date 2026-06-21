# Templates

Use this directory for curated, reusable template artifacts.

The entry paths are intentionally flat. Pick a starter or reference repo directly from this directory instead of drilling into extra category folders first.

## File Tree

```text
.
|-- README.md
|-- nixos-classic-starter/
|-- nixos-flake-starter/
|-- luo216-nix-config/
|-- ryan4yin-nix-config/
|-- ryan4yin-nix-config-dma-shell/
|-- ryan4yin-nix-config-i3-kickstarter/
`-- ryan4yin-nix-config-migrate-idols-ai/
```

## Conventions

- keep template entry paths flat
- include a short README in each starter or reference repo
- keep starter templates minimal and composable
- prefer placeholders over machine-specific values
- keep large real-world repos as references, not mandatory defaults

## Quick Picks

- Want the smallest possible `/etc/nixos` starting point:
  `nixos-classic-starter/`
- Want the smallest flake-based starting point:
  `nixos-flake-starter/`
- Want a real multi-host reference with Home Manager, overlays, and custom packages:
  `luo216-nix-config/`
- Want a large upstream flake monorepo reference:
  `ryan4yin-nix-config/`
- Want an easier upstream learning branch:
  `ryan4yin-nix-config-i3-kickstarter/`
- Want an opinionated upstream branch variant:
  `ryan4yin-nix-config-dma-shell/` or `ryan4yin-nix-config-migrate-idols-ai/`

## Grouped Index

- Starter templates:
  `nixos-classic-starter/`, `nixos-flake-starter/`
- Reference repos:
  `luo216-nix-config/`, `ryan4yin-nix-config/`, `ryan4yin-nix-config-dma-shell/`, `ryan4yin-nix-config-i3-kickstarter/`, `ryan4yin-nix-config-migrate-idols-ai/`
- Simpler learning path:
  `nixos-classic-starter/`, `nixos-flake-starter/`, `ryan4yin-nix-config-i3-kickstarter/`
- Heavier real-world examples:
  `luo216-nix-config/`, `ryan4yin-nix-config/`, `ryan4yin-nix-config-dma-shell/`, `ryan4yin-nix-config-migrate-idols-ai/`

Current curated templates:

- Naming rule:
  Personal templates append the owner's GitHub username suffix, then append the branch name only when it is not `main` or `master`.

- `luo216-nix-config/`
  A real-world modular flake repo with multi-host NixOS, Home Manager, `disko`, overlays, custom packages, and host factor files.

- `ryan4yin-nix-config/`
  Ryan4Yin's upstream default branch template, kept as a high-signal reference for large-scale flake repo structure.

- `ryan4yin-nix-config-dma-shell/`
  Ryan4Yin's `dma-shell` branch template.

- `ryan4yin-nix-config-i3-kickstarter/`
  Ryan4Yin's `i3-kickstarter` branch template, explicitly recommended upstream as a simpler branch for learning.

- `ryan4yin-nix-config-migrate-idols-ai/`
  Ryan4Yin's `migrate-idols-ai` branch template.

- `nixos-classic-starter/`
  Minimal official-style non-flake `/etc/nixos` starter with `configuration.nix` and placeholder `hardware-configuration.nix`.

- `nixos-flake-starter/`
  Minimal official-style flake starter with `flake.nix`, `configuration.nix`, and placeholder `hardware-configuration.nix`.
