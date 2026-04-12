{ pkgs, ... }:
{
  # -----------------------------------------------------------------------
  # X11 + LightDM + i3
  # -----------------------------------------------------------------------
  services.xserver = {
    enable = true;

    xkb.layout = "us";
    xkb.variant = "";

    # LightDM: no Qt dependency, correct pairing for standalone WMs
    displayManager.lightdm = {
      enable = true;
      greeters.gtk.enable = true;
    };

    displayManager.defaultSession = "none+i3";

    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        i3status
        i3blocks
        i3lock
        dmenu
        xss-lock     # Screen locker integration
      ];
    };
  };

  # -----------------------------------------------------------------------
  # XDG portals (screen sharing, file picker, URI handling)
  # -----------------------------------------------------------------------
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "*";
  };

  # -----------------------------------------------------------------------
  # Fonts
  # -----------------------------------------------------------------------
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      nerd-fonts.iosevka           # Primary terminal font (Alacritty config)
      nerd-fonts.hack
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
      noto-fonts
      noto-fonts-emoji
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
