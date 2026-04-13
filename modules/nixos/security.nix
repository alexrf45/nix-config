{ pkgs, ... }:
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
  # GNOME Keyring (git credential storage, SSH key passphrase caching)
  # -----------------------------------------------------------------------
  security.pam.services.login.enableGnomeKeyring = true;
  services.gnome.gnome-keyring.enable = true;

  # -----------------------------------------------------------------------
  # 1Password system integration
  # polkitPolicyOwners grants fr3d permission to use the SSH agent and GUI
  # -----------------------------------------------------------------------
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "fr3d" ];
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
    ];
    # SSH public key for remote access — update with your key
    # openssh.authorizedKeys.keys = [
    #   "ssh-ed25519 AAAAC3... fr3d@horus"
    # ];
  };

  # zsh must be declared as a system shell for login shells to work
  programs.zsh.enable = true;
}
