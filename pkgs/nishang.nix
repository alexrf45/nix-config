# Nishang — offensive PowerShell framework (samratashok/nishang).
# Not in nixpkgs; vendored as the upstream source tree (PowerShell scripts).
# Installed to $out/share/nishang; exported via NISHANG_DIR in the security devShells.
#
# Update procedure:
#   1. Get the latest commit:
#        curl -s https://api.github.com/repos/samratashok/nishang/commits/master \
#          | sed -n 's/.*"sha": "\([0-9a-f]*\)".*/\1/p' | head -1
#   2. Recompute the tarball hash (see pkgs/linpeas.nix for commands), URL
#      https://github.com/samratashok/nishang/archive/<rev>.tar.gz

{ stdenvNoCC, fetchurl }:

let
  rev = "d87229d2112456470ad30a50edbf312463f2b09a";
in
stdenvNoCC.mkDerivation {
  pname = "nishang";
  version = "0-unstable-2026-06-01"; # pinned commit ${rev}

  src = fetchurl {
    url = "https://github.com/samratashok/nishang/archive/${rev}.tar.gz";
    hash = "sha256-/Aan9c3K4824BjraraRrPsK73KbhqqS65bLK7b+C4AQ=";
  };

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/nishang
    cp -r ./* $out/share/nishang/
    runHook postInstall
  '';

  meta = {
    description = "Offensive PowerShell scripts for pentesting and red teaming";
    homepage = "https://github.com/samratashok/nishang";
    platforms = [ "x86_64-linux" ];
  };
}
