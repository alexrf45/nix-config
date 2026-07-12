{ pkgs, lib, ... }:
{
  # -----------------------------------------------------------------------
  # SSH daemon
  # -----------------------------------------------------------------------
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      PubkeyAuthentication = true;
    };
  };

  # -----------------------------------------------------------------------
  # sudo
  # -----------------------------------------------------------------------
  security.sudo.wheelNeedsPassword = true;

  # -----------------------------------------------------------------------
  # Polkit (required for 1password, mounting, desktop agents)
  # -----------------------------------------------------------------------
  security.polkit.enable = true;

  # -----------------------------------------------------------------------
  # GNOME Keyring (git credential storage)
  # SSH component is intentionally disabled — 1Password handles SSH auth.
  # enableGnomeKeyring starts the keyring SSH agent via PAM which would
  # set SSH_AUTH_SOCK and conflict with IdentityAgent in ~/.ssh/config.
  # -----------------------------------------------------------------------
  security.pam.services.login.enableGnomeKeyring = lib.mkForce false;
  services.gnome.gnome-keyring.enable = true;

  # -----------------------------------------------------------------------
  # 1Password system integration
  # polkitPolicyOwners grants fr3d permission to use the SSH agent and GUI
  # -----------------------------------------------------------------------
  programs._1password = {
    enable = true;
    package = pkgs._1password-cli-beta;
  };
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "fr3d" ];
    package = pkgs._1password-gui-beta;
  };

  # -----------------------------------------------------------------------
  # Wireshark — capture privileges without root.
  # Sets setcap on dumpcap and creates the `wireshark` group; members capture
  # live traffic unprivileged. Installs the Qt GUI + tshark system-wide (so the
  # plain `wireshark` package is dropped from dev-tools.nix to avoid duplication).
  # -----------------------------------------------------------------------
  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };

  # -----------------------------------------------------------------------
  # User declaration
  # -----------------------------------------------------------------------
  users.users.fr3d = {
    isNormalUser = true;
    description = "fr3d";
    shell = pkgs.zsh;
    extraGroups = [
      "wheel"
      "networkmanager"
      "docker"
      "audio"
      "video"
      "input"
      "bluetooth"
      "wireshark"
    ];
    # SSH public key for remote access — update with your key
    # openssh.authorizedKeys.keys = [
    #   "ssh-ed25519 AAAAC3... fr3d@horus"
    # ];
  };

  # zsh must be declared as a system shell for login shells to work
  programs.zsh.enable = true;
}
