# ---------------------------------------------------------------------------
# REGENERATE ON THE TARGET MACHINE DURING INSTALL:
#   nixos-generate-config --show-hardware-config > hosts/thoth/hardware-configuration.nix
#
# The values below were derived from the live Debian system (Intel i5-1155G7,
# NVMe on nvme0n1, /home on the separate sda1 disk). Root/boot/swap live on
# nvme0n1 and are reformatted during a fresh install, so their UUIDs WILL
# change — regenerate this file after partitioning. The /home partition
# (sda1, UUID d1d58667-…) is preserved untouched, so its entry stays valid.
#
# NOTE: Intel VMD is active on this laptop — the `vmd` initrd module is
# REQUIRED or the NVMe drive will not be found at boot. Keep it in the list.
# ---------------------------------------------------------------------------
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "vmd" "xhci_pci" "nvme" "ahci" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # Root + /nix/store — nvme0n1p2 (reformatted on install; UUID changes).
  fileSystems."/" =
    { device = "/dev/disk/by-uuid/1c7666ff-ecfd-4c0e-a624-ecfa1275aa3c";
      fsType = "ext4";
    };

  # EFI System Partition — nvme0n1p1 (1G, vfat). Mounted at /boot for
  # systemd-boot. UUID changes if the ESP is reformatted.
  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/B7FD-9729";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  # /home on the separate 476G SSD (sda1) — PRESERVED across the reinstall.
  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/d1d58667-0d96-4ccd-8716-11717c51a291";
      fsType = "ext4";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/2d4b616e-7998-4529-9c56-510464cdf4eb"; }
    ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
