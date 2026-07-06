{ inputs, outputs, pkgs, pkgs-unstable, config, lib, ... }:
{
  imports = [
    # SOPS home-manager module (for user-level secrets if needed)
    inputs.sops-nix.homeManagerModules.sops

    # Shared Home Manager modules
    ../../../modules/home-manager/shell.nix
    ../../../modules/home-manager/terminal.nix
    ../../../modules/home-manager/editor.nix
    ../../../modules/home-manager/tmux.nix
    ../../../modules/home-manager/git.nix
    ../../../modules/home-manager/desktop-i3.nix   # i3 (X11) — thoth-specific
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
  # thoth-specific GUI apps (daily-driver desktop software from Debian).
  # CLI tools and the browsers live in the shared packages.nix module.
  # -----------------------------------------------------------------------
  home.packages = with pkgs; [
    discord
    slack
    vlc
    obs-studio
    remmina          # RDP/VNC client
    gimp
  ];

  # -----------------------------------------------------------------------
  # thoth-specific shell aliases
  # -----------------------------------------------------------------------
  programs.zsh.shellAliases = {
    # Edit SOPS secrets on thoth. Derives the age private key from the SSH
    # host key on the fly so it never touches disk in plaintext.
    # Usage: sops-thoth secrets/thoth.yaml
    sops-thoth = "SOPS_AGE_KEY=$(sudo cat /etc/ssh/ssh_host_ed25519_key | ${pkgs.ssh-to-age}/bin/ssh-to-age -private-key) sops";
  };

  # -----------------------------------------------------------------------
  # SOPS user-level secrets (optional — extend as needed)
  # -----------------------------------------------------------------------
  # sops = {
  #   defaultSopsFile = ../../../secrets/thoth.yaml;
  #   age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
  # };
}
