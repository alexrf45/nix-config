# Example standalone Home Manager profile for non-NixOS machines (Kali, Ubuntu,
# a cloud box, ...). Installs the toolkit + shell into the user's profile only.
#
#   nix run home-manager/master -- switch --flake .#fr3d
{ ... }:
{
  home.username = "fr3d";
  home.homeDirectory = "/home/fr3d";
  home.stateVersion = "24.11";

  programs.home-manager.enable = true;

  # Pick the categories you want; all default to off.
  securityLab = {
    enable = true;
    offensive = {
      network = true;
      web = true;
      activeDirectory = true;
      osint = true;
      passwords = true;
      pivoting = true;
    };
    defensive = {
      monitoring = true;
      hardening = true;
    };
    secrets = true;
  };
}
