# NixOS Config

## Purpose

This repository houses NixOS flake configurations for personal use across two laptops.

## Hosts

| Host    | Machine                     | GPU               | Desktop        | Role                          |
|---------|-----------------------------|-------------------|----------------|-------------------------------|
| `horus` | Acer Nitro 5                | AMD iGPU + NVIDIA | Sway (Wayland) | primary workstation           |
| `thoth` | Intel i5-1155G7 laptop      | Intel Iris Xe     | i3 (X11)       | security-research daily driver |

Build/switch a host with `sudo nixos-rebuild switch --flake .#<host>`.

Shared modules live in `modules/nixos` and `modules/home-manager`; host-specific
hardware/desktop variants are split out (e.g. `hardware.nix` vs `hardware-intel.nix`,
`desktop.nix` (Sway) vs `desktop-x11.nix` (i3), HM `desktop.nix` vs `desktop-i3.nix`).

## Hardware

### horus — Acer Nitro 5

- **Machine**: Acer Nitro 5 — AMD Ryzen CPU + NVIDIA discrete GPU
- **RAM**: 32GB
- **Storage**:

  ```
  sda  476.9G
    sda1 470G /home/anubis (used to store research and other bulk files)
  sdb  953.9G
    sdb1  1G    /boot  (EFI, vfat)
    sdb2  4G    [SWAP]
    sdb3  948.9G  /  (ext4, also hosts /nix/store)
  ```

### thoth — Intel Tiger Lake laptop

- **Machine**: Intel i5-1155G7 (Tiger Lake), Iris Xe iGPU only, 38GB RAM
- **WiFi**: Realtek RTL8821CE (rtw88_8821ce, in-tree) — no wired NIC
- **Boot**: UEFI + systemd-boot. **Intel VMD is active** — the `vmd` initrd
  module is REQUIRED or the NVMe disk won't be found at boot.
- **Storage**:

  ```
  nvme0n1  (NixOS target — reformatted on install)
    nvme0n1p1  1G      /boot  (EFI, vfat)
    nvme0n1p2  ~470G   /      (ext4, also hosts /nix/store)
    nvme0n1p3  ~4G     [SWAP]
  sda        476.9G
    sda1     470G      /home  (ext4 — PRESERVED across the reinstall)
  ```

- **Network mount**: CIFS `//192.168.20.106/home-drive` → `/mnt/home-drive`
  (systemd automount; credentials at `/etc/nixos/smb-secrets`, prefer sops).

## Configuration Structure

```
hosts/horus/          — horus host entry, hardware-configuration.nix, disk docs
hosts/thoth/          — thoth host entry, hardware-configuration.nix, storage.nix (CIFS)
modules/nixos/         — System modules: hardware(-intel), networking, security, desktop(-x11), audio, virtualisation, nix-settings
modules/home-manager/  — HM modules: shell, terminal, editor, tmux, git, desktop(-i3), dev-tools, packages
home-manager/horus/fr3d/  — horus user HM entry point
home-manager/thoth/fr3d/  — thoth user HM entry point
overlays/              — Unstable packages overlay (1password, claude-code)
dotfiles/              — Mirrored dotfiles from github.com/alexrf45/dotfiles
tmuxp/                 — tmuxp session files (homelab, security, dev)
secrets/               — SOPS-encrypted secrets (age-encrypted .yaml files)
```

## Key Design Decisions

- **nixpkgs**: `nixos-26.05` stable + `nixos-unstable` overlay for select packages
- **Home Manager**: NixOS-integrated module (`useGlobalPkgs = true`)
- **Overlays**: Declared in `hosts/horus/default.nix` — NOT inside home.nix
- **GPU**: NVIDIA PRIME offload mode (AMD iGPU drives display, NVIDIA on demand)
- **Sound**: PipeWire + WirePlumber (PulseAudio compat shim enabled)
- **Display**: GDM + Sway
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
- Tools: 1password (CLI+GUI beta), terraform, claude-code, docker, tmux, neovim, SOPS, Age
- Dev envs: Python, Go, Security/CTF
- Reference: <https://github.com/alexrf45/h0me>, <https://github.com/alexrf45/dotfiles>

## Security devShells (CTF / pentesting)

Disposable per-engagement toolchains modeled on [SCRT](https://github.com/alexrf45/SCRT),
exposed as flake `devShells` (defined in `flake.nix` from `pkgs-sec` = unstable + unfree +
the `additions` overlay). Tools are NOT installed into the system profile — enter a shell:

```bash
nix develop .#web        # recon + web fuzzing (ProjectDiscovery, ffuf, sqlmap, wpscan, …)
nix develop .#ad         # Active Directory / Windows (impacket, netexec, bloodhound, …)
nix develop .#forensics  # forensics / stego / cracking (vol3, steghide, john, seclists, …)
nix develop .#ctf        # pwn / RE / crypto (radare2, ropgadget, gdb+gef, pwntools, z3) [= default]
```

Pwn basics (`pwntools`, `gdb`, `gef`, `binutils`) also live always-on in `dev-tools.nix`.
The `.#ad` shell exports `$RUBEUS`, `$CERTIFY`, `$WINPEAS`, `$NISHANG_DIR` for the vendored
Windows tools. Always-on ergonomics (independent of any shell): pentest zsh aliases +
`~/.proxychains/proxychains.conf` (`modules/home-manager/security.nix`), a `ctf` tmuxp
session (`tmuxp load ctf`), and unprivileged Wireshark capture (`programs.wireshark`, user in
the `wireshark` group). The firewall already opens TCP 22/8080/8000 for serving payloads.

### Vendored security tools (not in nixpkgs)

`pkgs/{linpeas,winpeas,pspy,sharpcollection,nishang}.nix` pin upstream release assets with
SRI hashes and are registered in `overlays/additions.nix`. To bump a version: follow the
update header in each file (resolve the new tag/commit, recompute the hash with
`nix-prefetch-url <url>` or `curl -sSL <url> | openssl dgst -sha256 -binary | base64`).

## Git Workflow

All changes go to the `dev` branch before merging to `main`.
