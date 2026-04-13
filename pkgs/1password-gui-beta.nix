# 1Password GUI — beta channel, pinned to latest release.
#
# Update procedure when 1Password releases a new beta:
#   1. curl -sL https://downloads.1password.com/linux/tar/beta/x86_64/1password-latest.tar.gz -o /tmp/1p.tar.gz
#   2. tar -tzf /tmp/1p.tar.gz | head -1        # get version string
#   3. python3 -c "
#        import hashlib, base64
#        print('sha256-' + base64.b64encode(hashlib.sha256(open('/tmp/1p.tar.gz','rb').read()).digest()).decode())
#      "
#   4. Update version + hash below.

{ _1password-gui, fetchurl }:

(_1password-gui.override { channel = "beta"; }).overrideAttrs (_: rec {
  version = "8.12.10-38.BETA";
  src = fetchurl {
    url = "https://downloads.1password.com/linux/tar/beta/x86_64/1password-${version}.x64.tar.gz";
    hash = "sha256-bnm+6Q0ScGi2DtS6Sdo+aOZVhTeYlqahpTfgQfYU/P4=";
  };
})
