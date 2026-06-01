# NixOS module: installs the selected security toolkit system-wide and wires up
# a few capabilities that raw-socket tools need.
{ config, lib, pkgs, ... }:
let
  cfg = config.securityLab;
  packages = import ./select.nix { inherit pkgs lib cfg; };
in
{
  imports = [ ./options.nix ];

  config = lib.mkIf cfg.enable {
    environment.systemPackages = packages;

    # Wireshark with the dumpcap setcap wrapper + a `wireshark` group, so
    # captures work without running the whole GUI as root.
    programs.wireshark.enable = lib.mkIf (cfg.defensive.all || cfg.defensive.monitoring) true;

    # Suricata/Zeek and most scanners want generous fd limits under load.
    security.pam.loginLimits = lib.mkIf cfg.enable [
      { domain = "*"; type = "soft"; item = "nofile"; value = "65536"; }
      { domain = "*"; type = "hard"; item = "nofile"; value = "65536"; }
    ];
  };
}
