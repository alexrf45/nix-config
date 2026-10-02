{pkgs, ...}: {
  # -----------------------------------------------------------------------
  # Kindle-over-USB plumbing for calibre.
  #
  # Kindles speak one of two protocols depending on generation, and calibre
  # needs different host-side support for each — so both are wired up here.
  # The calibre GUI itself is a user package (home-manager/thoth/fr3d).
  # -----------------------------------------------------------------------

  # USB mass storage Kindles (Basic, older Paperwhite/Oasis): the device shows
  # up as a block device. calibre does NOT mount it itself — it drives udisks2
  # over D-Bus, so without this the device is detected and then fails to open.
  # polkit grants the local active session the mount, so no group membership
  # is needed. Also gives the desktop generic USB-drive mounting.
  services.udisks2.enable = true;

  # MTP Kindles (Scribe, newer Paperwhite): no block device — calibre talks to
  # it through its bundled libmtp driver, which needs raw USB access.
  # libmtp's 69-libmtp.rules autoprobes the device and tags it
  # ID_MEDIA_PLAYER=1; systemd's 70-uaccess.rules then grants the logged-in
  # user access off that tag. Rule ordering (69 before 70) is what makes it
  # work — don't renumber.
  #
  # `.out` is required: libmtp is multi-output and `pkgs.libmtp` is the `bin`
  # output, which carries no rules — the rules and hwdb live in `out`. Dropping
  # the suffix makes this line a silent no-op.
  services.udev.packages = [pkgs.libmtp.out];
}
