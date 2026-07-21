{
  inputs,
  outputs,
  pkgs,
  pkgs-unstable,
  lib,
  ...
}: {
  imports = [
    # SOPS home-manager module (for user-level secrets if needed)
    inputs.sops-nix.homeManagerModules.sops

    # Home Manager modules
    ../../../modules/home-manager/shell.nix
    ../../../modules/home-manager/terminal.nix
    ../../../modules/home-manager/editor.nix
    ../../../modules/home-manager/tmux.nix
    ../../../modules/home-manager/git.nix
    ../../../modules/home-manager/desktop-i3.nix # i3 (X11) — aligned with thoth
    ../../../modules/home-manager/dev-tools
    ../../../modules/home-manager/packages.nix
    ../../../modules/home-manager/security.nix
    ../../../modules/home-manager/ssh.nix
  ];

  home = {
    username = "fr3d";
    homeDirectory = "/home/fr3d";
    stateVersion = "24.11"; # Set once — never change
  };

  # i3 per-host knobs (shared modules/home-manager/desktop-i3.nix).
  local.i3 = {
    wirelessInterface = "wlp1s0"; # TODO(horus): verify with `ip link`
    primaryOutput = null; # no forced external monitor; keep the panel on
  };

  # Reload systemd user services on Home Manager activation
  systemd.user.startServices = "sd-switch";

  programs.home-manager.enable = true;

  # XDG base directory spec
  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
      setSessionVariables = false;
    };
  };

  # Font discovery for user-installed fonts
  fonts.fontconfig.enable = true;

  # -----------------------------------------------------------------------
  # SOPS user-level secrets (optional — extend as needed)
  # -----------------------------------------------------------------------
  # sops = {
  #   defaultSopsFile = ../../../secrets/horus.yaml;
  #   age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
  # };
}
