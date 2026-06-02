# linPEAS — Linux Privilege Escalation Awesome Script (PEASS-ng).
# Not in nixpkgs; vendored from upstream release assets.
#
# Update procedure:
#   1. Find the latest tag:
#        curl -sI https://github.com/peass-ng/PEASS-ng/releases/latest \
#          | sed -n 's/^location:.*tag\///p' | tr -d '\r'
#   2. Recompute the hash (either tool works):
#        nix-prefetch-url --type sha256 \
#          https://github.com/peass-ng/PEASS-ng/releases/download/<tag>/linpeas.sh
#        # or: curl -sSL <url> | openssl dgst -sha256 -binary | base64   (prefix with sha256-)
#   3. Update version + hash below.

{ stdenvNoCC, fetchurl }:

stdenvNoCC.mkDerivation rec {
  pname = "linpeas";
  version = "20260601-a39c90f1";

  src = fetchurl {
    url = "https://github.com/peass-ng/PEASS-ng/releases/download/${version}/linpeas.sh";
    hash = "sha256-ZRv4OfMS03BVjsTUgzTbAq8HtBIfKfZE7vjKkuA3PMI=";
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/linpeas
    runHook postInstall
  '';

  meta = {
    description = "Linux local privilege escalation enumeration script (PEASS-ng)";
    homepage = "https://github.com/peass-ng/PEASS-ng";
    platforms = [ "x86_64-linux" ];
  };
}
