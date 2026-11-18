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

{ _1password-gui, fetchurl, polkitPolicyOwners ? [] }:

(_1password-gui.override { channel = "beta"; inherit polkitPolicyOwners; }).overrideAttrs (_: rec {
  version = "8.12.48-24.BETA";
  src = fetchurl {
    url = "https://downloads.1password.com/linux/tar/beta/x86_64/1password-${version}.x64.tar.gz";
    hash = "sha256-wXU6tAsBxKGhCVxyoLO66eaP30HE9WibzAGdf9b3QU4=";
  };

  # 8.12.48 renamed the desktop file; nixpkgs' installPhase still expects the old name.
  postPatch = ''
    mv resources/com.onepassword.OnePassword.desktop resources/1password.desktop
  '';

  # nixpkgs patchelfs only 4 binaries; 8.12.48 aborts when these helpers fail to load.
  postInstall = ''
    for helper in chrome_crashpad_handler 1Password-Crash-Handler 1password-mcp; do
      patchelf \
        --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
        --set-rpath "$(patchelf --print-rpath $out/share/1password/1password)" \
        $out/share/1password/$helper
    done
  '';
})
