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

## horus only — NVIDIA PRIME bus IDs

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
