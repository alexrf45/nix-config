# winPEAS — Windows Privilege Escalation Awesome Script (PEASS-ng).
# A Windows PE binary, NOT runnable on Linux — installed to $out/bin so it is
# discoverable on PATH for copying onto a target. Use the WINPEAS env var
# exported by the security devShells.
#
# Update procedure: same tag/hash workflow as pkgs/linpeas.nix, asset winPEASx64.exe.

{ stdenvNoCC, fetchurl }:

stdenvNoCC.mkDerivation rec {
  pname = "winpeas";
  version = "20260601-a39c90f1";

  src = fetchurl {
    url = "https://github.com/peass-ng/PEASS-ng/releases/download/${version}/winPEASx64.exe";
    hash = "sha256-gJ61CDoQATFH2g46EIXdwTq8Fz0OLnMsQvGDTLQBQSM=";
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    install -Dm644 $src $out/bin/winPEASx64.exe
    runHook postInstall
  '';

  meta = {
    description = "Windows local privilege escalation enumeration binary (PEASS-ng)";
    homepage = "https://github.com/peass-ng/PEASS-ng";
    platforms = [ "x86_64-linux" ];
  };
}
