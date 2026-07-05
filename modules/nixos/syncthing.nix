{ ... }:
{
  services.syncthing = {
    enable = true;
    user = "fr3d";
    dataDir = "/home/fr3d";
    configDir = "/home/fr3d/.config/syncthing";
    openDefaultPorts = true;
  };
}
