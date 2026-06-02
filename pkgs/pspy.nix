# pspy — snoop on processes without root (DominicBreuker/pspy).
# Not in nixpkgs; vendored prebuilt static Linux binaries (pspy64 + pspy64s).
#
# Update procedure:
#   1. Latest tag:
#        curl -sI https://github.com/DominicBreuker/pspy/releases/latest \
#          | sed -n 's/^location:.*tag\///p' | tr -d '\r'
#   2. Recompute hashes for pspy64 and pspy64s (see pkgs/linpeas.nix for commands).

{ stdenvNoCC, fetchurl }:

stdenvNoCC.mkDerivation rec {
  pname = "pspy";
  version = "1.2.1";

  pspy64 = fetchurl {
    url = "https://github.com/DominicBreuker/pspy/releases/download/v${version}/pspy64";
    hash = "sha256-yT8ppcwTR725DhShJCTmRpyM/qmiC4ALwkl1XwBDo7s=";
  };

  pspy64s = fetchurl {
    url = "https://github.com/DominicBreuker/pspy/releases/download/v${version}/pspy64s";
    hash = "sha256-4Cd8Fk+sstD7lWgqd4h92Qiw4drLKKK8r9ZyizSDVCU=";
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 $pspy64  $out/bin/pspy64
    install -Dm755 $pspy64s $out/bin/pspy64s
    ln -s pspy64 $out/bin/pspy
    runHook postInstall
  '';

  meta = {
    description = "Monitor Linux processes without root permissions";
    homepage = "https://github.com/DominicBreuker/pspy";
    platforms = [ "x86_64-linux" ];
  };
}
