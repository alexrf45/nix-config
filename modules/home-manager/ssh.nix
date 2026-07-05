{ pkgs, lib, ... }:
{
  # -----------------------------------------------------------------------
  # SSH client — 1Password SSH agent + CAC PKCS#11 authentication
  # IdentityAgent routes all SSH auth through the 1Password agent socket.
  # PKCS11Provider is scoped to DoD hosts only to avoid PIN prompts and
  # OpenSC load failures on connections where no smart card is present.
  # -----------------------------------------------------------------------
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    extraConfig = ''
      IdentityAgent ~/.1password/agent.sock
    '';
    settings."*.mil" = {
      PKCS11Provider = "${pkgs.opensc}/lib/opensc-pkcs11.so";
    };
  };

  # 1Password SSH agent — expose keys from all relevant vaults.
  # Private vault is the default; HomeLab holds infrastructure keys.
  xdg.configFile."1Password/ssh/agent.toml".text = ''
    [[ssh-keys]]
    vault = "Private"

    [[ssh-keys]]
    vault = "HomeLab"
  '';

  # GTK PIN entry dialog — works under Sway/Wayland (via XWayland), non-GNOME
  home.packages = [ pkgs.pinentry-gtk2 ];

  # -----------------------------------------------------------------------
  # Chrome / Brave NSS database registration
  # Chromium-family browsers use ~/.pki/nssdb for client certificates.
  # Creates the DB if absent, then registers OpenSC — idempotent on re-runs.
  # -----------------------------------------------------------------------
  home.activation.registerCACinNSSDB = lib.hm.dag.entryAfter ["writeBoundary"] ''
    NSSDB="$HOME/.pki/nssdb"
    mkdir -p "$NSSDB"
    # Initialize the SQLite NSS DB only if it isn't already present. certutil
    # needs the directory to exist first and will not create it itself.
    if [ ! -f "$NSSDB/cert9.db" ]; then
      ${pkgs.nssTools}/bin/certutil -d "sql:$NSSDB" -N --empty-password
    fi
    ${pkgs.nssTools}/bin/modutil \
      -dbdir "sql:$NSSDB" \
      -add "OpenSC PKCS11" \
      -libfile "${pkgs.opensc}/lib/opensc-pkcs11.so" \
      -force 2>/dev/null || true
  '';
}
