{ pkgs, config, ... }:
# Network and storage mounts for thoth. Physical disks (/, /boot, /home, swap)
# live in hardware-configuration.nix; this file holds the CIFS share to the NAS.
#
# SMB credentials are managed by sops-nix. The secret is rendered to
# /run/secrets/smb-home-drive (root-only, 0400) and referenced by the mount.
#
# One-time setup (run from the repo root):
#   sops secrets/thoth.yaml
#   # Add the following block (replace values for your NAS):
#   #   smb-home-drive-credentials: |
#   #     username=myuser
#   #     password=mypass
#   #     domain=WORKGROUP
{
  # cifs-utils provides mount.cifs, required for the SMB mount below.
  environment.systemPackages = [ pkgs.cifs-utils ];

  # Render NAS credentials to /run/secrets/smb-home-drive (tmpfs, cleared on reboot).
  # sops.age.keyFile is declared once in luks-data-drive.nix.
  sops.secrets."smb-home-drive-credentials" = {
    sopsFile = ../../secrets/thoth.yaml;
    mode     = "0400";
  };

  # ---------------------------------------------------------------------------
  # CIFS/SMB mount — //192.168.20.106/home-drive (home lab NAS).
  #
  # Uses systemd automount so a missing/offline NAS never blocks boot: the
  # share is mounted lazily on first access to /mnt/home-drive and unmounted
  # after idle.
  # ---------------------------------------------------------------------------
  fileSystems."/mnt/home-drive" = {
    device = "//192.168.20.106/home-drive";
    fsType = "cifs";
    options = [
      "credentials=${config.sops.secrets."smb-home-drive-credentials".path}"
      "uid=1000"
      "gid=1000"
      "iocharset=utf8"
      "vers=3.0"
      "x-systemd.automount"
      "x-systemd.idle-timeout=600"
      "x-systemd.requires=sops-install-secrets.service"
      "x-systemd.after=sops-install-secrets.service"
      "noauto"
      "_netdev"
    ];
  };
}
