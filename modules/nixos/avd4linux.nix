{ pkgs, ... }:
{
  # -----------------------------------------------------------------------
  # Azure Virtual Desktop — work access from home (avd4linux)
  # Entra ID certificate-based sign-in with the CAC, then FreeRDP with the
  # reader redirected into the remote Windows session (MS-RDPESC).
  #
  # Relies on smartcard.nix: pcscd + ccid for the reader, and the p11-kit
  # opensc.module that WebKit's TLS stack uses to present the PIV cert.
  #
  # Usage: avd4linux [--cloud dod|gcc|commercial]   (default: dod)
  #        avd4linux --list-smartcard-certs         (card/cert sanity check)
  #
  # Webcam (MS-RDPECAM) is not available: nixpkgs FreeRDP is built without the
  # rdpecam channel. Microphone redirection works.
  # -----------------------------------------------------------------------
  environment.systemPackages = [ pkgs.avd4linux ];
}
