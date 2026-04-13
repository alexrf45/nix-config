{ ... }:
{
  networking = {
    networkmanager.enable = true;

    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 8080 8000];
      # Extend as needed:
      #   allowedTCPPorts = [ 22 8080 ];
      #   allowedUDPPorts = [ 51820 ];  # WireGuard
    };
  };

  # Time synchronization
  services.timesyncd.enable = true;
  time.timeZone = "America/New_York";

  # Locale
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ALL = "en_US.UTF-8";
    };
  };
  console.keyMap = "us";
}
