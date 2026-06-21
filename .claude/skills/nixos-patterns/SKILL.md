---
name: nixos-patterns
description: Reusable NixOS, Home Manager, and flake configuration patterns. Use when planner or implementer needs proven directory structures, module split patterns, host layouts, secrets organization, overlays, or template-style examples instead of abstract explanation.
---

# NixOS Patterns

Use this skill when the task is not "does this exist in nixpkgs?" but "what is a strong way to structure this configuration?"

## Scope

- Flake repository layouts
- Multi-host configuration splits
- Desktop and server organization patterns
- Home Manager layout patterns
- Secrets placement patterns
- Overlay and package-extension patterns

## Usage Rule

- Prefer this skill for template selection, directory structure advice, and example layouts.
- Prefer `nixos` for conceptual explanation.
- Prefer `nixpkgs-inspector` when existence or definition location must be verified.

## File Tree

```text
.
|-- SKILL.md
`-- templates/
    |-- README.md
    |-- nixos-classic-starter/
    |-- nixos-flake-starter/
    |-- luo216-nix-config/
    |-- ryan4yin-nix-config/
    |-- ryan4yin-nix-config-dma-shell/
    |-- ryan4yin-nix-config-i3-kickstarter/
    `-- ryan4yin-nix-config-migrate-idols-ai/
```

## Templates

Use `templates/` for concrete skeletons and real-world repository examples. Template entry paths are intentionally flat so users can jump straight to the selected starter or reference repo.

- `templates/README.md`
  Template storage conventions and current index.
