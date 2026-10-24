{pkgs, ...}: {
  # -----------------------------------------------------------------------
  # Xorg + i3 (X11) — faithful port of the Debian daily driver.
  # Per-user i3 keybindings/bars/startup live in
  # modules/home-manager/desktop-i3.nix.
  # -----------------------------------------------------------------------
  services.xserver = {
    enable = true;

    xkb = {
      layout = "us";
      variant = "";
    };

    # i3 window manager. The bulk of the runtime tools (rofi, picom, feh, …)
    # are managed per-user in Home Manager; these are the session essentials.
    windowManager.i3 = {
      enable = true;
      package = pkgs.i3;
      extraPackages = with pkgs; [
        i3status # Status line generator (drives the i3bar)
        i3lock # Screen locker
        dmenu # Fallback launcher (rofi is the primary via HM)
      ];
    };
  };

  # LightDM display manager with the GTK greeter (mirrors Debian's lightdm).
  services.xserver.displayManager.lightdm = {
    enable = true;
    greeters.gtk = {
      enable = true;
      extraConfig = "font-name = Iosevka Aile 11";
    };
  };

  # Boot straight into the i3 session.
  services.displayManager.defaultSession = "none+i3";

  # -----------------------------------------------------------------------
  # XDG portals (file picker, screenshot, URI handling under X11)
  # -----------------------------------------------------------------------
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
    config.common.default = "*";
  };

  # -----------------------------------------------------------------------
  # Fonts — Iosevka everywhere: Nerd Font (mono), Aile (sans), Etoile (serif).
  # -----------------------------------------------------------------------
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      font-awesome # i3blocks/i3status glyphs
      nerd-fonts.iosevka # Monospace (kitty, i3, rofi, dunst)
      (iosevka-bin.override {variant = "Aile";}) # Sans
      (iosevka-bin.override {variant = "Etoile";}) # Serif
      noto-fonts # Fallback for glyphs Iosevka lacks
      noto-fonts-color-emoji
      liberation_ttf
    ];
    fontconfig = {
      defaultFonts = {
        monospace = ["Iosevka Nerd Font Mono"];
        sansSerif = ["Iosevka Aile"];
        serif = ["Iosevka Etoile"];
        emoji = ["Noto Color Emoji"];
      };
    };
  };

  # VA-API hardware video decode is a per-GPU concern and lives in the host
  # hardware module (LIBVA_DRIVER_NAME: iHD on thoth, radeonsi on horus).
}
