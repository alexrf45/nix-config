{pkgs, ...}: {
  # -----------------------------------------------------------------------
  # Sway (Wayland) session — layered on desktop-x11.nix (GDM, fonts, xkb).
  # Per-user keybindings live in modules/home-manager/desktop.nix.
  # -----------------------------------------------------------------------
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraPackages = with pkgs; [
      grim # Screenshot capture
      slurp # Region selection (for screenshots)
      satty # Annotation editor for screenshots (replaces flameshot's GUI)
      wl-clipboard # Wayland clipboard (wl-copy / wl-paste)
    ];
  };

  # wlroots portal for screen sharing under Sway (gtk portal comes from desktop-x11.nix).
  xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-wlr];
}
