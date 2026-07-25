{pkgs, ...}: {
  # -----------------------------------------------------------------------
  # MangoHud — FPS/perf overlay. Opt-in per game via Steam launch options
  # (`mangohud %command%`), not session-wide.
  # -----------------------------------------------------------------------
  programs.mangohud.enable = true;

  # -----------------------------------------------------------------------
  # protonup-ng — installs/updates Proton-GE builds into
  # ~/.steam/root/compatibilitytools.d; Steam picks them up automatically.
  # -----------------------------------------------------------------------
  home.packages = [
    pkgs.protonup-ng
  ];
}
