# NixOS module index — exported as outputs.nixosModules.* for external consumption.
# Within this repo, modules are imported by path in hosts/horus/default.nix.
{
  hardware        = import ./hardware.nix;          # horus — AMD + NVIDIA
  hardwareIntel   = import ./hardware-intel.nix;    # thoth — Intel Iris Xe
  networking      = import ./networking.nix;
  security        = import ./security.nix;
  desktop         = import ./desktop.nix;           # horus — Sway (Wayland)
  desktopX11      = import ./desktop-x11.nix;       # thoth — i3 (X11)
  audio           = import ./audio.nix;
  virtualisation  = import ./virtualisation.nix;
  nixSettings     = import ./nix-settings.nix;
}
