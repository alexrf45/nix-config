{
  inputs,
  outputs,
  pkgs-unstable,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./disk.nix

    # NixOS system modules
    ../../modules/nixos/nix-settings.nix
    ../../modules/nixos/hardware.nix
    ../../modules/nixos/networking.nix
    ../../modules/nixos/security.nix
    ../../modules/nixos/desktop-x11.nix # Xorg + i3 (aligned with thoth)
    ../../modules/nixos/audio.nix
    ../../modules/nixos/virtualisation.nix
    ../../modules/nixos/smartcard.nix
    ../../modules/nixos/syncthing.nix

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
        users.fr3d = import ../../home-manager/horus/fr3d;
      };
    }
  ];

  networking.hostName = "horus";

  # Set once during initial install — never change after activation
  system.stateVersion = "25.11";
}
