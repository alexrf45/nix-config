{ pkgs, pkgs-unstable, ... }:
{
  # -----------------------------------------------------------------------
  # General user packages — CLI tools, utilities, fonts
  # -----------------------------------------------------------------------
  home.packages = with pkgs; [
    # Shell enhancements
    fzf
    fd
    ripgrep
    bat
    eza                  # Modern ls (replaces exa, which is archived)
    zoxide               # Smart cd
    delta                # Better git diff
    jq
    yq-go
    tldr
    htop
    btop
    ncdu                 # Disk usage browser
    tree

    # File management
    rsync
    p7zip
    unzip
    unrar
    aria2                # Download manager (aria2c)

    # Network tools
    dig
    whois
    traceroute
    ipcalc

    # Media
    spotify-player       # TUI Spotify client (mirrors dotfiles `alias spotify`)

    # Productivity
    lazygit

    # Fonts (additional user-level fonts)
    font-awesome

    # VPN
    openvpn

    # Scripts directory — managed as home.file
  ];

  # -----------------------------------------------------------------------
  # Scripts from dotfiles — placed at ~/.config/scripts/
  # -----------------------------------------------------------------------
  xdg.configFile."scripts" = {
    source = ../../../dotfiles/scripts;
    recursive = true;
    executable = true;
  };

  # -----------------------------------------------------------------------
  # Starship config — mirrors .config/starship.toml from dotfiles
  # -----------------------------------------------------------------------
  xdg.configFile."starship.toml".source = ../../../dotfiles/starship.toml;

  # -----------------------------------------------------------------------
  # tmuxp session files — placed at ~/.config/tmuxp/
  # Aliases in aliases.zsh reference these paths
  # -----------------------------------------------------------------------
  xdg.configFile."tmuxp/homelab.yaml".source = ../../../tmuxp/homelab.yaml;
  xdg.configFile."tmuxp/security.yaml".source = ../../../tmuxp/security.yaml;
  xdg.configFile."tmuxp/dev.yaml".source      = ../../../tmuxp/dev.yaml;

  # -----------------------------------------------------------------------
  # k9s skin
  # -----------------------------------------------------------------------
  xdg.configFile."k9s" = {
    source = ../../../dotfiles/k9s;
    recursive = true;
  };

  # -----------------------------------------------------------------------
  # Session environment (mirrors .zprofile)
  # -----------------------------------------------------------------------
  home.sessionVariables = {
    AWS_REGION           = "us-east-1";
    AWS_VAULT_BACKEND    = "pass";
    AWS_CLI_AUTO_PROMPT  = "on-partial";
    DOCKER_BUILDKIT      = "1";
    KUBECONFIG           = "$HOME/.kube/config";
    KUBECTL_KUBERC       = "true";
    KUBE_EDITOR          = "nvim";
    FZF_DEFAULT_OPTS     = ''
      --color=fg:-1,fg+:#d0d0d0,bg:-1,bg+:#262626
      --color=hl:#5fb079,hl+:#43fb00,info:#afaf87,marker:#87ff00
      --color=prompt:#06fd34,spinner:#f2ff5e,pointer:#fbfbfb,header:#87afaf
      --color=border:#2B3328,preview-fg:#f1f8f2,query:#e97b7b
      --border="rounded" --preview-window="border-rounded" --prompt="> "
      --marker=">" --pointer="" --separator="─" --scrollbar="│"
    '';
    FZF_COMPLETION_TRIGGER = "..";
    FZF_COMPLETION_OPTS  = "--border --info=inline";
  };
}
