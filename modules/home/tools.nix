# Operator quality-of-life CLI tools — the SCRT "base"/"main" apt sets, plus the
# binaries the shell functions/aliases depend on (miniserve, mkcert, age).
{ pkgs, ... }:
{
  programs.bat.enable = true;

  home.packages = with pkgs; [
    # core CLI
    jq
    fd
    ripgrep
    tree
    aria2
    fastfetch
    p7zip
    rlwrap
    file
    unzip
    wget
    curl
    git
    tmux

    # depended on by shell functions (webserver / cert-gen / encrypt_age)
    miniserve
    mkcert
    age
  ];
}
