# GhostPack Windows offensive .NET binaries (Rubeus, Certify) — precompiled,
# vendored from Flangvik/SharpCollection pinned to a commit. These are Windows
# PE binaries, NOT runnable on Linux; installed to $out/bin for discovery and
# exported via the RUBEUS / CERTIFY env vars in the security devShells.
#
# Update procedure:
#   1. Get the latest commit:
#        curl -s https://api.github.com/repos/Flangvik/SharpCollection/commits/master \
#          | sed -n 's/.*"sha": "\([0-9a-f]*\)".*/\1/p' | head -1
#   2. Recompute hashes for each .exe (see pkgs/linpeas.nix for commands).
#   3. Update rev + hashes below. .NET framework dir may change (NetFramework_4.7_x64).

{ stdenvNoCC, fetchurl }:

let
  rev = "bb11a24424b237c79692eca57d74f06a90f2fbd3";
  base = "https://github.com/Flangvik/SharpCollection/raw/${rev}/NetFramework_4.7_x64";
in
stdenvNoCC.mkDerivation {
  pname = "sharpcollection-bins";
  version = "0-unstable-2026-06-01"; # pinned commit ${rev}

  rubeus = fetchurl {
    url = "${base}/Rubeus.exe";
    hash = "sha256-otlbwxLCws5DCAB/0EMDaTzK3vgO5c5pXlCBWmCOfn8=";
  };

  certify = fetchurl {
    url = "${base}/Certify.exe";
    hash = "sha256-YYUMU+dVTfr59crLLS3fqdwbTbR9iWBwWNi0wNGhgMM=";
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    install -Dm644 $rubeus  $out/bin/Rubeus.exe
    install -Dm644 $certify $out/bin/Certify.exe
    runHook postInstall
  '';

  meta = {
    description = "Precompiled GhostPack Rubeus + Certify (.NET, Windows)";
    homepage = "https://github.com/Flangvik/SharpCollection";
    platforms = [ "x86_64-linux" ];
  };
}
