# First activation (bootstrap a host)

One-time steps to bring up a host from a fresh NixOS install. Day-to-day rebuilds just use
`/rebuild` (`sudo nixos-rebuild switch --flake .#<host>`).

```bash
# 1. Generate the age key and add its public key to .sops.yaml
age-keygen -o ~/.config/sops/age/keys.txt

# 2. Capture the real hardware config for the host
nixos-generate-config --show-hardware-config > hosts/<host>/hardware-configuration.nix

# 3. Build and switch
sudo nixos-rebuild switch --flake .#<host>
```

## horus only — NVIDIA PRIME bus IDs (retired host)

> horus is retired (2026-09). This applies only if reviving it.

The PRIME bus IDs in `modules/nixos/hardware.nix` are host-specific. Derive them on the
physical machine and update the values:

```bash
lspci | grep -E 'VGA|3D'
# Format: "XX:YY.Z"  →  "PCI:XX:YY:Z"
```

## thoth only — reminders

- The `vmd` initrd module must stay enabled (Intel VMD; the NVMe disk won't be found without it).
- `/home` (sda1) is preserved across reinstall — do not reformat it.
- CIFS `/mnt/home-drive` credentials live at `/etc/nixos/smb-secrets` (prefer migrating to sops).
- `vault-task-sync` runs from a working checkout, not the Nix store. On a fresh
  host the timer fails until it exists:

  ```sh
  git clone git@github.com:alexrf45/vault-task-sync.git ~/code/vault-task-sync
  cd ~/code/vault-task-sync && bun install
  ```

  Its two sops keys (`vault-task-sync-credentials`, `vault-task-sync-token`) must
  also be present in `secrets/thoth.yaml` *before* the first rebuild that includes
  `modules/nixos/vault-task-sync.nix`, or activation fails. See that file's header.
