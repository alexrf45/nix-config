{ pkgs, ... }:
{
  # -----------------------------------------------------------------------
  # PC/SC daemon — USB smart card middleware
  # plugins must explicitly list pkgs.ccid; enable alone provides no driver.
  # SCR3310 uses the USB CCID class protocol.
  # -----------------------------------------------------------------------
  services.pcscd = {
    enable = true;
    plugins = [ pkgs.ccid ];
  };

  # -----------------------------------------------------------------------
  # Packages
  # opensc:     PIV/CAC PKCS#11 provider (covers all DoD CAC since ~2013)
  # pcsc-tools: pcsc_scan for reader/card diagnostics
  # p11-kit:    unified PKCS#11 broker (browser + SSH share one module reg)
  # nsstools:   modutil/certutil for NSS database management
  # -----------------------------------------------------------------------
  environment.systemPackages = with pkgs; [
    opensc
    pcsc-tools
    p11-kit
    nsstools
  ];

  # -----------------------------------------------------------------------
  # p11-kit module registration
  # Creates /etc/pkcs11/modules/opensc.module so Firefox, p11tool, etc.
  # discover OpenSC automatically via the p11-kit broker.
  # -----------------------------------------------------------------------
  environment.etc."pkcs11/modules/opensc.module".text = ''
    module: ${pkgs.opensc}/lib/opensc-pkcs11.so
    critical: no
  '';

  # -----------------------------------------------------------------------
  # plugdev group — non-root USB reader access
  # ccid's udev rules grant plugdev rw access to CCID-class readers.
  # extraGroups here merges with security.nix's list via NixOS module system.
  # -----------------------------------------------------------------------
  users.groups.plugdev = {};
  users.users.fr3d.extraGroups = [ "plugdev" ];
}
