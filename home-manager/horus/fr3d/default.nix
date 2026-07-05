{ inputs, outputs, pkgs, pkgs-unstable, config, lib, ... }:
{
  imports = [
    # SOPS home-manager module (for user-level secrets if needed)
    inputs.sops-nix.homeManagerModules.sops

    # Home Manager modules
    ../../../modules/home-manager/shell.nix
    ../../../modules/home-manager/terminal.nix
    ../../../modules/home-manager/editor.nix
    ../../../modules/home-manager/tmux.nix
    ../../../modules/home-manager/git.nix
    ../../../modules/home-manager/desktop.nix
    ../../../modules/home-manager/dev-tools.nix
    ../../../modules/home-manager/packages.nix
    ../../../modules/home-manager/security.nix
    ../../../modules/home-manager/ssh.nix
  ];

  home = {
    username    = "fr3d";
    homeDirectory = "/home/fr3d";
    stateVersion = "24.11";   # Set once — never change
  };

  # Reload systemd user services on Home Manager activation
  systemd.user.startServices = "sd-switch";

  programs.home-manager.enable = true;

  # Wayland-native emacs build for Sway — overrides emacs30 (GTK3) from editor.nix
  programs.emacs.package = pkgs.emacs30-pgtk;

  # direnv — per-project nix shells (python venvs, go workspaces, etc.)
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true;
  };

  # XDG base directory spec
  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = false;
      setSessionVariables = false;
      desktop    = "/dev/null";
      documents  = "/dev/null";
      download   = "${config.home.homeDirectory}/.downloads";
      music      = "/dev/null";
      pictures   = "/dev/null";
      publicShare = "/dev/null";
      templates  = "/dev/null";
      videos     = "/dev/null";
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
