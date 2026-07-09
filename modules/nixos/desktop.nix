{ pkgs, ... }:
{
  # -----------------------------------------------------------------------
  # GDM + Sway (Wayland)
  # -----------------------------------------------------------------------
  # Keyboard layout (consumed by GDM and the console; no Xorg required).
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # GDM display manager — runs on Wayland by default, correct host for Sway.
  services.displayManager.gdm.enable = true;

  # Sway compositor — sets up the wrapper, polkit, and required system bits.
  # Per-user keybindings/bars live in modules/home-manager/desktop.nix.
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraOptions = [ "--unsupported-gpu" ];
    extraPackages = with pkgs; [
      swaylock      # Screen locker
      swayidle      # Idle management (lock/DPMS)
      swaybg        # Wallpaper
      grim          # Screenshot capture
      slurp         # Region selection (for screenshots)
      wl-clipboard  # Wayland clipboard (wl-copy / wl-paste)
      wmenu         # dmenu-equivalent launcher for Wayland
    ];
  };

  # -----------------------------------------------------------------------
  # XDG portals (screen sharing, file picker, URI handling)
  # -----------------------------------------------------------------------
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-wlr   # wlroots backend for screen sharing under Sway
    ];
    config.common.default = "*";
  };

  # -----------------------------------------------------------------------
  # Fonts
  # -----------------------------------------------------------------------
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      nerd-fonts.iosevka           # Primary terminal font (kitty config)
      nerd-fonts.hack
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
      noto-fonts
      noto-fonts-color-emoji
      liberation_ttf
    ];
    fontconfig = {
      defaultFonts = {
        monospace = [ "Iosevka Nerd Font Mono" ];
        sansSerif  = [ "Noto Sans" ];
        serif      = [ "Noto Serif" ];
      };
    };
  };

  # -----------------------------------------------------------------------
  # Session environment
  # -----------------------------------------------------------------------
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "radeonsi";   # AMD VA-API hardware video decode
  };
}
