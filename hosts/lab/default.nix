# Example NixOS host: a security research lab box.
#
# This wires the securityLab module + Home Manager together. Enable only the
# categories you actually want — every toggle defaults to off.
{ pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  # ---- security toolkit (system-wide) ----------------------------------
  securityLab = {
    enable = true;
    offensive = {
      network = true;
      web = true;
      activeDirectory = true;
      osint = true;
      passwords = true;
      pivoting = true;
      privesc = true;
      ctf = true;
      # wireless = true;       # aircrack-ng, bettercap, kismet
      # exploitation = true;   # metasploit, searchsploit
    };
    defensive = {
      ids = true;
      forensics = true;
      malwareAnalysis = true;
      monitoring = true;
      hardening = true;
    };
    secrets = true;
    # extras = true;           # opt-in; verify attr names first (see catalog.nix)
  };

  # ---- per-user shell environment via Home Manager ---------------------
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.fr3d = { ... }: {
    imports = [ ../../modules/home ];
    home.stateVersion = "24.11";
  };

  # ---- baseline system -------------------------------------------------
  users.users.fr3d = {
    isNormalUser = true;
    description = "security researcher";
    extraGroups = [ "wheel" "networkmanager" "wireshark" ];
    shell = pkgs.zsh;
  };
  programs.zsh.enable = true;

  # ghidra and a few forensics tools are unfree.
  nixpkgs.config.allowUnfree = true;

  networking.hostName = "lab";
  networking.networkmanager.enable = true;
  services.openssh.enable = true;
  time.timeZone = "America/New_York";

  # Pin the release you track. Do not change after first install.
  system.stateVersion = "24.11";
}
