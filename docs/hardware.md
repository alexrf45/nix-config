# Hardware reference

Detailed hardware, storage, and boot facts for each host. The critical, easy-to-forget ones
are called out as **gotchas**.

## horus — Acer Nitro 5

- **Machine:** Acer Nitro 5 — AMD Ryzen CPU + NVIDIA discrete GPU
- **RAM:** 32GB
- **GPU:** AMD iGPU drives the display; NVIDIA on demand via PRIME offload.
- **Gotcha:** the NVIDIA PRIME bus IDs in `modules/nixos/hardware.nix` are host-specific — see
  `docs/bootstrap.md` to derive and set them.
- **Storage:**

  ```
  sda  476.9G
    sda1 470G     /home/anubis  (research and bulk files)
  sdb  953.9G
    sdb1 1G       /boot  (EFI, vfat)
    sdb2 4G       [SWAP]
    sdb3 948.9G   /  (ext4, also hosts /nix/store)
  ```

## thoth — Intel Tiger Lake laptop

- **Machine:** Intel i5-1155G7 (Tiger Lake), Iris Xe iGPU only, 38GB RAM
- **WiFi:** Realtek RTL8821CE (`rtw88_8821ce`, in-tree) — no wired NIC
- **Boot:** UEFI + systemd-boot. **Gotcha: Intel VMD is active — the `vmd` initrd module is
  REQUIRED or the NVMe disk isn't found at boot.**
- **Storage:**

  ```
  nvme0n1  (NixOS target — reformatted on install)
    nvme0n1p1  1G      /boot  (EFI, vfat)
    nvme0n1p2  ~470G   /      (ext4, also hosts /nix/store)
    nvme0n1p3  ~4G     [SWAP]
  sda        476.9G
    sda1     470G      /home  (ext4 — PRESERVED across reinstall)
  ```

- **Network mount:** CIFS `//192.168.20.106/home-drive` → `/mnt/home-drive` (systemd automount;
  credentials at `/etc/nixos/smb-secrets`, prefer sops). Defined in `hosts/thoth/storage.nix`.
