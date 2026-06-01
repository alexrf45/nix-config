# Home Manager module: installs the selected security toolkit into a single
# user's profile. Use this on non-NixOS machines (Ubuntu, Kali, macOS-linux
# remotes, etc.) where you want the tools without touching the system.
#
# Note: tools needing raw sockets or setuid (masscan SYN scans, naabu, wireshark
# capture) still require the corresponding system capability/permission. On
# NixOS prefer modules/security/nixos.nix for those.
{ config, lib, pkgs, ... }:
let
  cfg = config.securityLab;
  packages = import ./select.nix { inherit pkgs lib cfg; };
in
{
  imports = [ ./options.nix ];

  config = lib.mkIf cfg.enable {
    home.packages = packages;
  };
}
