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
    greeters.gtk.enable = true;
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
  # Fonts — JetBrains Mono / Nerd Fonts, matching the Debian setup.
  # -----------------------------------------------------------------------
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono # Primary UI/terminal font (i3 + kitty)
      nerd-fonts.ubuntu-mono # i3bar font ("UbuntuMono Nerd Font")
      nerd-fonts.fira-code
      nerd-fonts.hack
      font-awesome # i3blocks/i3status glyphs
      noto-fonts
      noto-fonts-color-emoji
      nerd-fonts.iosevka # Terminal font referenced by kitty (terminal.nix)
      liberation_ttf
    ];
    fontconfig = {
      defaultFonts = {
        monospace = ["JetBrainsMono Nerd Font Mono"];
        sansSerif = ["Noto Sans"];
        serif = ["Noto Serif"];
      };
    };
  };

  # VA-API hardware video decode is a per-GPU concern and lives in the host
  # hardware module (LIBVA_DRIVER_NAME: iHD on thoth, radeonsi on horus).
}
