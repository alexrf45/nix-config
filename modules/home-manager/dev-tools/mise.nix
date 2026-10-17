{pkgs-unstable, ...}: {
  # mise — portable per-project tools/env/tasks via mise.toml; devenv stays for system libs/services.
  programs.mise = {
    enable = true;
    package = pkgs-unstable.mise; # stable is pre-2026.8; retire once stable catches up
    enableBashIntegration = true;
  };

  # conf.d fragment keeps ~/.config/mise/config.toml writable for `mise use -g`.
  xdg.configFile."mise/conf.d/nix.toml".text = ''
    [settings]
    all_compile = false # precompiled builds via nix-ld; default from mise 2027.8
  '';
}
