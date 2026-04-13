# NixOS module index — exported as outputs.nixosModules.* for external consumption.
# Within this repo, modules are imported by path in hosts/horus/default.nix.
{
  hardware        = import ./hardware.nix;
  networking      = import ./networking.nix;
  security        = import ./security.nix;
  desktop         = import ./desktop.nix;
  audio           = import ./audio.nix;
  virtualisation  = import ./virtualisation.nix;
  nixSettings     = import ./nix-settings.nix;
}
