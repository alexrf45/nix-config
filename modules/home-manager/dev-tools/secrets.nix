{ pkgs, ... }:
{
  home.packages = with pkgs; [
    sops
    age
    age-plugin-yubikey
  ];
}
