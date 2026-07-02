{ pkgs, ... }:
# Network mounts for thoth. Physical disks (/, /boot, /home, swap) live in
# hardware-configuration.nix; this file holds only the CIFS share to the NAS,
# which nixos-generate-config does not capture.
{
  # cifs-utils provides mount.cifs, required for the SMB mount below.
  environment.systemPackages = [ pkgs.cifs-utils ];

  # ---------------------------------------------------------------------------
  # CIFS/SMB mount — //192.168.20.106/home-drive (home lab NAS).
  #
  # Uses systemd automount so a missing/offline NAS never blocks boot: the
  # share is mounted lazily on first access to /mnt/home-drive and unmounted
  # after idle.
  #
  # Credentials: create the file below (root-only, 0600) with:
  #   username=<user>
  #   password=<pass>
  #   domain=<domain-or-WORKGROUP>
  # Prefer managing it through sops-nix — e.g. a secret rendered to
  # /run/secrets/smb-home-drive — then point credentials= at that path.
  # ---------------------------------------------------------------------------
  fileSystems."/mnt/home-drive" = {
    device = "//192.168.20.106/home-drive";
    fsType = "cifs";
    options = [
      "credentials=/etc/nixos/smb-secrets"
      "uid=1000"
      "gid=1000"
      "iocharset=utf8"
      "vers=3.0"
      "x-systemd.automount"
      "x-systemd.idle-timeout=600"
      "noauto"
      "_netdev"
    ];
  };
}
