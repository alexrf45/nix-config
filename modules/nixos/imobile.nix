{ pkgs, ... }:
{
  # -----------------------------------------------------------------------
  # usbmuxd — USB multiplexing daemon for iOS devices
  # Brokers all communication with a plugged-in iPhone/iPad over the lightning
  # /USB-C cable. enable alone is enough; the daemon handles device access, so
  # no custom udev rules or plugdev membership are required (unlike smartcard).
  # If pairing or mounting misbehaves, swap in the newer daemon:
  #   package = pkgs.usbmuxd2;
  # -----------------------------------------------------------------------
  services.usbmuxd.enable = true;

  # -----------------------------------------------------------------------
  # Packages
  # libimobiledevice: idevicepair (trust/pair), idevicebackup2 (full backup),
  #                   ideviceinfo, etc. — the core iOS-over-USB toolset
  # ifuse:            mount the device filesystem via FUSE ('ifuse <mountpoint>')
  # -----------------------------------------------------------------------
  environment.systemPackages = with pkgs; [
    libimobiledevice
    ifuse
    imessage-exporter # export the backed-up Messages DB to TXT/HTML (overlays/additions.nix)
  ];
}
