# NixOS Config

## Purpose

This repository houses NixOS flake configurations for personal use on an Acer Nitro 5.

## Hardware

- **Machine**: Acer Nitro 5 — AMD Ryzen CPU + NVIDIA discrete GPU
- **RAM**: 32GB
- **Storage**:
  ```
  sda  476.9G  (secondary, unmounted by default)
  sdb  953.9G
    sdb1  1G    /boot  (EFI, vfat)
    sdb2  4G    [SWAP]
    sdb3  948.9G  /  (ext4, also hosts /nix/store)
  ```

## Configuration Structure

```
hosts/horus/          — Host entry, hardware-configuration.nix, disk docs
modules/nixos/         — System modules: hardware, networking, security, desktop, audio, virtualisation, nix-settings
modules/home-manager/  — HM modules: shell, terminal, editor, tmux, git, desktop, dev-tools, packages
home-manager/horus/fr3d/  — User HM entry point
overlays/              — Unstable packages overlay (1password, claude-code)
dotfiles/              — Mirrored dotfiles from github.com/alexrf45/dotfiles
tmuxp/                 — tmuxp session files (homelab, security, dev)
secrets/               — SOPS-encrypted secrets (age-encrypted .yaml files)
```

## Key Design Decisions

- **nixpkgs**: `nixos-24.11` stable + `nixos-unstable` overlay for select packages
- **Home Manager**: NixOS-integrated module (`useGlobalPkgs = true`)
- **Overlays**: Declared in `hosts/horus/default.nix` — NOT inside home.nix
- **GPU**: NVIDIA PRIME offload mode (AMD iGPU drives display, NVIDIA on demand)
- **Sound**: PipeWire + WirePlumber (PulseAudio compat shim enabled)
- **Display**: X11 + LightDM + i3
- **Secrets**: SOPS + Age (key at `~/.config/sops/age/keys.txt`, never in repo)

## PRIME Bus IDs — ACTION REQUIRED

The NVIDIA PRIME bus IDs in `modules/nixos/hardware.nix` are PLACEHOLDERS.
Run this on the physical machine and update the values:

```bash
lspci | grep -E 'VGA|3D'
# Format: "XX:YY.Z" → "PCI:XX:YY:Z"
```

## First Activation

```bash
# 1. Generate age key
age-keygen -o ~/.config/sops/age/keys.txt
# Copy public key to .sops.yaml

# 2. Replace hardware-configuration.nix with actual output
nixos-generate-config --show-hardware-config > hosts/horus/hardware-configuration.nix

# 3. Update PRIME bus IDs in modules/nixos/hardware.nix

# 4. Build and switch
sudo nixos-rebuild switch --flake .#horus
```

## Requirements

- Sound, input, video (AMD+NVIDIA), wireless, Bluetooth
- Shell: zsh (modular config mirrored from dotfiles)
- Tools: 1password (CLI+GUI beta), terraform, kubectl, k9s, claude-code, docker, flux, helm, tmux, neovim, SOPS, Age
- Dev envs: Python, Go, Security/CTF, Home Lab
- Reference: <https://github.com/alexrf45/home-0ps.com>, <https://github.com/alexrf45/dotfiles>

## Git Workflow

All changes go to the `dev` branch before merging to `main`.
