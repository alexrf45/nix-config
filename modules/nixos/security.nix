{ pkgs, lib, config, ... }:
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

  # gdm-password sets useDefaultRules = false and only substacks `login`, so the mkForce
  # above left the keyring locked under GDM; enableGnomeKeyring is ignored there.
  security.pam.services.gdm-password.rules = {
    auth.gnome_keyring = {
      control = "optional";
      modulePath = "${pkgs.gnome-keyring}/lib/security/pam_gnome_keyring.so";
      order = config.security.pam.services.gdm-password.rules.auth.login.order + 100;
    };
    session.gnome_keyring = {
      control = "optional";
      modulePath = "${pkgs.gnome-keyring}/lib/security/pam_gnome_keyring.so";
      settings.auto_start = true;
      order = config.security.pam.services.gdm-password.rules.session.login.order + 100;
    };
  };

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
    shell = pkgs.bashInteractive;
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

  # bashInteractive is NixOS's default user shell and is always present in
  # /etc/shells, so no `programs.<shell>.enable` declaration is needed here.
  # (Was `programs.zsh.enable = true` before the 2026-09-13 bash migration.)
}
