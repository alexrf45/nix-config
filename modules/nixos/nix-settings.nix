{ pkgs, ... }:
{
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      trusted-users = [ "root" "fr3d" ];
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
    gc = {
      automatic = true;
      persistent = true;   # run missed GC on next boot (important for laptops)
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  # Allow unfree packages system-wide (NVIDIA, 1password, etc.)
  nixpkgs.config.allowUnfree = true;

  # nix-ld — run dynamically linked binaries (e.g. Terraform providers
  # downloaded from registries) that expect a standard FHS interpreter.
  programs.nix-ld.enable = true;

  # Useful system-level utilities available to all users
  environment.systemPackages = with pkgs; [
    git
    wget
    curl
    vim
    file
    which
    lsof
    htop
    pciutils   # lspci — needed to identify PRIME bus IDs
    usbutils   # lsusb
    dmidecode  # hardware info
  ];
}
