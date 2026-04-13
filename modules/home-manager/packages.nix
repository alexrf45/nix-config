{ pkgs, pkgs-unstable, ... }:
{
  # -----------------------------------------------------------------------
  # General user packages — CLI tools, utilities, fonts
  # -----------------------------------------------------------------------
  home.packages = with pkgs; [
    # Shell enhancements
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

    # Web browsers
    brave
    google-chrome    # CAC-authenticated DoD portals
  ];

  # -----------------------------------------------------------------------
  # Scripts from dotfiles — placed at ~/.config/scripts/
  # -----------------------------------------------------------------------
  xdg.configFile."scripts" = {
    source = ../../dotfiles/scripts;
    recursive = true;
    executable = true;
  };

  # -----------------------------------------------------------------------
  # Starship config — mirrors .config/starship.toml from dotfiles
  # -----------------------------------------------------------------------
  xdg.configFile."starship.toml".source = ../../dotfiles/starship.toml;

  # -----------------------------------------------------------------------
  # tmuxp session files — placed at ~/.config/tmuxp/
  # Aliases in aliases.zsh reference these paths
  # -----------------------------------------------------------------------
  xdg.configFile."tmuxp/homelab.yaml".source = ../../tmuxp/homelab.yaml;
  xdg.configFile."tmuxp/security.yaml".source = ../../tmuxp/security.yaml;
  xdg.configFile."tmuxp/dev.yaml".source      = ../../tmuxp/dev.yaml;

  # -----------------------------------------------------------------------
  # Firefox — managed via programs module for profile/settings control
  # security.osclientcerts.autoload exposes OS trust anchors via p11-kit.
  # For full CAC client auth, load OpenSC manually once in Firefox:
  #   Preferences → Privacy & Security → Security Devices → Load
  #   Path: /run/current-system/sw/lib/opensc-pkcs11.so
  # -----------------------------------------------------------------------
  programs.firefox = {
    enable = true;
    profiles.default = {
      settings = {
        "security.osclientcerts.autoload" = true;
        # Some DoD sites still require older TLS — allow TLS 1.0+
        "security.tls.version.min" = 1;
      };
    };
  };

  # -----------------------------------------------------------------------
  # fzf — use programs.fzf.defaultOptions (list of strings) to avoid shell
  # redirection issues: bare > in FZF_DEFAULT_OPTS via sessionVariables gets
  # interpreted as a redirect operator, creating junk files in $HOME.
  # -----------------------------------------------------------------------
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultOptions = [
      "--color=fg:-1,fg+:#d0d0d0,bg:-1,bg+:#262626"
      "--color=hl:#5fb079,hl+:#43fb00,info:#afaf87,marker:#87ff00"
      "--color=prompt:#06fd34,spinner:#f2ff5e,pointer:#fbfbfb,header:#87afaf"
      "--color=border:#2B3328,preview-fg:#f1f8f2,query:#e97b7b"
      "--border=rounded"
      "--preview-window=border-rounded"
      "--prompt=> "
      "--marker=>"
      "--pointer=\uf054"
      "--separator=─"
      "--scrollbar=│"
    ];
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
    FZF_COMPLETION_TRIGGER = "..";
    FZF_COMPLETION_OPTS    = "--border --info=inline";
  };
}
