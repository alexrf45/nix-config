# PLACEHOLDER — replace with your real hardware config.
#
# On the target machine run:
#   sudo nixos-generate-config --show-hardware-config > hosts/lab/hardware-configuration.nix
#
# The stub below only exists so `nix flake check` has something to evaluate; it
# will NOT boot a real machine as-is.
{ lib, modulesPath, ... }:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
