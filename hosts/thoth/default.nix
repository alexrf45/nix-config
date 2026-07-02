{ inputs, outputs, pkgs-unstable, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./storage.nix

    # NixOS system modules
    ../../modules/nixos/nix-settings.nix
    ../../modules/nixos/hardware-intel.nix   # Intel Iris Xe (thoth-specific)
    ../../modules/nixos/networking.nix
    ../../modules/nixos/security.nix
    ../../modules/nixos/desktop-x11.nix      # Xorg + i3 (thoth-specific)
    ../../modules/nixos/audio.nix
    ../../modules/nixos/virtualisation.nix
    ../../modules/nixos/smartcard.nix

    # SOPS-nix system module
    inputs.sops-nix.nixosModules.sops

    # Home Manager as NixOS module
    inputs.home-manager.nixosModules.home-manager
    {
      # CRITICAL: overlays declared here, NOT inside any home.nix
      # With useGlobalPkgs = true, overlays inside home.nix are silently ignored.
      nixpkgs.overlays = [
        outputs.overlays.additions
        outputs.overlays.modifications
        outputs.overlays.unstable-packages
      ];

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs = {
          inherit inputs outputs pkgs-unstable;
        };
        users.fr3d = import ../../home-manager/thoth/fr3d;
      };
    }
  ];

  networking.hostName = "thoth";

  # Tailscale mesh VPN (mirrors the Debian tailscale setup).
  services.tailscale.enable = true;

  # libvirt/KVM + virt-manager (mirrors the Debian QEMU/libvirt setup).
  # Docker is already enabled by modules/nixos/virtualisation.nix.
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
  users.users.fr3d.extraGroups = [ "libvirtd" "kvm" ];

  # Set once during initial install — never change after activation
  system.stateVersion = "25.11";
}
