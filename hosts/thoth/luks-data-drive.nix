{ pkgs, config, lib, ... }:
# Post-boot LUKS unlock for the secondary data drive (/dev/sda).
#
# How it works:
#   1. sops-nix decrypts `luks-sda-key` from secrets/thoth.yaml and renders it
#      to /run/secrets/luks-sda-key (root-only, 0400) during early activation.
#   2. cryptsetup-sda-data.service reads the key and opens the LUKS device.
#   3. The /mnt/data fileSystems entry mounts the opened mapper device.
#
# One-time setup (run on thoth before first nixos-rebuild switch):
#
#   # 1. Format the drive with LUKS
#   cryptsetup luksFormat /dev/sda
#
#   # 2. Generate a random keyfile and add it as a LUKS key slot
#   dd if=/dev/urandom bs=512 count=4 > /tmp/luks-sda.key
#   cryptsetup luksAddKey /dev/sda /tmp/luks-sda.key
#
#   # 3. Base64-encode the keyfile for storage in the SOPS YAML
#   base64 -w0 /tmp/luks-sda.key
#   # → paste the output as the value of luks-sda-key in secrets/thoth.yaml
#
#   # 4. Add the key to SOPS (from the repo root):
#   sops secrets/thoth.yaml
#   # Add: luks-sda-key: "<base64 output from step 3>"
#
#   # 5. Record the UUID (update driveUuid below):
#   blkid /dev/sda
#
#   # 6. Format the filesystem inside the opened container
#   cryptsetup luksOpen --key-file /tmp/luks-sda.key /dev/sda sda-data
#   mkfs.ext4 /dev/mapper/sda-data
#   cryptsetup luksClose sda-data
#
#   # 7. Shred the plaintext keyfile
#   shred -u /tmp/luks-sda.key
#
# Updating the UUID:
#   Replace the driveUuid value below with the UUID from `blkid /dev/sda`.

let
  mapperName = "sda-data";
  mountPoint = "/home/data";

  # Replace with the UUID from: blkid /dev/sda
  driveUuid = "fab681ec-5f90-47b0-876d-0065ac8fafa5";

  # The keyfile is stored base64-encoded in the SOPS secret; decode before use.
  unlockScript = pkgs.writeShellScript "unlock-sda-data" ''
    set -euo pipefail
    if [ -e /dev/mapper/${mapperName} ]; then
      echo "cryptsetup-${mapperName}: device already open, skipping"
      exit 0
    fi
    base64 -d ${config.sops.secrets."luks-sda-key".path} \
      | ${pkgs.cryptsetup}/bin/cryptsetup luksOpen \
          --key-file - \
          /dev/disk/by-uuid/${driveUuid} \
          ${mapperName}
  '';

  lockScript = pkgs.writeShellScript "lock-sda-data" ''
    ${pkgs.cryptsetup}/bin/cryptsetup luksClose ${mapperName} || true
  '';
in
{
  # ---------------------------------------------------------------------------
  # sops-nix wiring
  # ---------------------------------------------------------------------------

  # Use the machine's SSH host key as the age decryption key.
  # sops-nix converts it to age internally — no separate keys file needed.
  # Corresponding age public key is recorded in .sops.yaml.
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  # The LUKS keyfile — decrypted from secrets/thoth.yaml at activation time
  # and written to /run/secrets/luks-sda-key (tmpfs, root-only, cleared on reboot).
  sops.secrets."luks-sda-key" = {
    sopsFile = ../../secrets/thoth.yaml;
    mode     = "0400";
  };

  # ---------------------------------------------------------------------------
  # Systemd service: open the LUKS device
  # ---------------------------------------------------------------------------

  systemd.services."cryptsetup-${mapperName}" = {
    description = "Open LUKS data drive /dev/sda (${mapperName})";

    # Secrets are written by sops-nix during activation (not a persistent service),
    # so they are available in /run/secrets/ before any systemd services start.
    after    = [ "sysinit.target" ];
    requires = [];

    # Must finish before the mount unit tries to mount /mnt/data,
    # and wants the mount so it is triggered automatically after unlock.
    before   = [ "${builtins.replaceStrings ["/"] ["-"] (lib.removePrefix "/" mountPoint)}.mount" ];
    wants    = [ "${builtins.replaceStrings ["/"] ["-"] (lib.removePrefix "/" mountPoint)}.mount" ];

    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type            = "oneshot";
      RemainAfterExit = true;
      ExecStart       = unlockScript;
      ExecStop        = lockScript;
    };
  };

  # ---------------------------------------------------------------------------
  # Filesystem mount
  # ---------------------------------------------------------------------------

  fileSystems."${mountPoint}" = {
    device  = "/dev/mapper/${mapperName}";
    fsType  = "ext4";
    options = [
      "noauto"   # do not mount during initrd / early boot
      "nofail"   # do not block boot if the drive is absent
      "x-systemd.requires=cryptsetup-${mapperName}.service"
      "x-systemd.after=cryptsetup-${mapperName}.service"
    ];
  };
}
