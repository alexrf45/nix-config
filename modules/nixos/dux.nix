{pkgs-unstable, ...}: {
  # -----------------------------------------------------------------------
  # Dux Shell (duxlabs.dev) — bar/launcher/notifications/lock for the Sway session.
  # -----------------------------------------------------------------------
  # Stable 26.05 ships the pre-rebrand dms-shell 1.4; take 2.x from unstable.
  # Retire: switch to programs.dux-shell once stable carries it.
  programs.dms-shell = {
    enable = true;
    package = pkgs-unstable.dux-shell;
    quickshell.package = pkgs-unstable.quickshell;

    # Start only under Sway — graphical-session.target is also active under i3.
    systemd.target = "sway-session.target";

    # Built into 2.x; the stable module's extra deps are redundant.
    enableSystemMonitoring = false;
    enableVPN = false;
    enableCalendarEvents = false;
    enableClipboardPaste = false;
  };

  # The module defaults power-profiles-daemon on; it conflicts with TLP (hardware-intel.nix).
  services.power-profiles-daemon.enable = false;
}
