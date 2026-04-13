{ pkgs, lib, ... }:
{
  # -----------------------------------------------------------------------
  # SSH client — CAC PKCS#11 authentication
  # Global PKCS11Provider: SSH gracefully skips the CAC key if the server
  # doesn't accept it. To restrict to specific hosts only, comment out
  # extraConfig and uncomment the matchBlocks block below.
  # -----------------------------------------------------------------------
  programs.ssh = {
    enable = true;
    extraConfig = ''
      IdentityAgent ~/.1password/agent.sock
      PKCS11Provider ${pkgs.opensc}/lib/opensc-pkcs11.so
    '';
    # Restrict CAC auth to DoD hosts only (avoids PIN prompts elsewhere):
    # matchBlocks."*.mil" = {
    #   pkcs11Provider = "${pkgs.opensc}/lib/opensc-pkcs11.so";
    # };
  };

  # GTK2 PIN entry dialog — correct for i3/X11 (non-GNOME) environment
  home.packages = [ pkgs.pinentry-gtk2 ];

  # -----------------------------------------------------------------------
  # Chrome / Brave NSS database registration
  # Chromium-family browsers use ~/.pki/nssdb for client certificates.
  # Creates the DB if absent, then registers OpenSC — idempotent on re-runs.
  # -----------------------------------------------------------------------
  home.activation.registerCACinNSSDB = lib.hm.dag.entryAfter ["writeBoundary"] ''
    NSSDB="$HOME/.pki/nssdb"
    if [ ! -d "$NSSDB" ]; then
      ${pkgs.nssTools}/bin/certutil -d "sql:$NSSDB" -N --empty-password
    fi
    ${pkgs.nssTools}/bin/modutil \
      -dbdir "sql:$NSSDB" \
      -add "OpenSC PKCS11" \
      -libfile "${pkgs.opensc}/lib/opensc-pkcs11.so" \
      -force 2>/dev/null || true
  '';
}
