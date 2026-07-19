{ pkgs, pkgs-unstable, ... }:
{
  home.packages = [
    pkgs-unstable.claude-code
    pkgs-unstable.devenv
    pkgs._1password-gui-beta
  ];

  # direnv — auto-activates .envrc on cd; nix-direnv adds `use flake` and
  # `use devenv` support (nix-direnv 3.0+ supports devenv natively).
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };
}
