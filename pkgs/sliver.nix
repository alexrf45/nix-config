# Sliver — adversary emulation / C2 framework (BishopFox).
# Not in nixpkgs; vendored from upstream release binaries. The server asset is
# large (~267MB) because it embeds the cross-compilation assets used to build
# implants, so this only lands in the opt-in `c2` bundle.
#
# Update procedure:
#   1. Find the latest tag:
#        curl -sI https://github.com/BishopFox/sliver/releases/latest \
#          | sed -n 's/^location:.*tag\///p' | tr -d '\r'
#   2. Recompute both hashes (drop the leading v from the tag for `version`):
#        nix store prefetch-file --json --name sliver-server \
#          https://github.com/BishopFox/sliver/releases/download/<tag>/sliver-server_linux-amd64
#        nix store prefetch-file --json --name sliver-client \
#          https://github.com/BishopFox/sliver/releases/download/<tag>/sliver-client_linux-amd64
#   3. Update version + both hashes below.

{ stdenv, fetchurl, autoPatchelfHook }:

stdenv.mkDerivation rec {
  pname = "sliver";
  version = "1.7.3";

  srcServer = fetchurl {
    url = "https://github.com/BishopFox/sliver/releases/download/v${version}/sliver-server_linux-amd64";
    hash = "sha256-4yFuzRL25+l8tFiLtthccOyjvfrYsIGP/VPMsuNXzMg=";
  };

  srcClient = fetchurl {
    url = "https://github.com/BishopFox/sliver/releases/download/v${version}/sliver-client_linux-amd64";
    hash = "sha256-sOMooTHk1nnpsmhVLbmcotRgUbkgWmf5t/fBYomD2q4=";
  };

  dontUnpack = true;

  # The release binaries are Go+cgo ELFs; patch their interpreter/rpath for NixOS.
  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ stdenv.cc.cc.lib ];

  installPhase = ''
    runHook preInstall
    install -Dm755 $srcServer $out/bin/sliver-server
    install -Dm755 $srcClient $out/bin/sliver
    runHook postInstall
  '';

  meta = {
    description = "Adversary emulation and C2 framework (server + client)";
    homepage = "https://github.com/BishopFox/sliver";
    platforms = [ "x86_64-linux" ];
  };
}
