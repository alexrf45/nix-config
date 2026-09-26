{
  pkgs,
  pkgs-unstable,
  ...
}: {
  # -----------------------------------------------------------------------
  # General user packages — CLI tools, utilities, fonts
  # -----------------------------------------------------------------------
  home.packages = with pkgs; [
    # Shell enhancements
    uv # Python package/venv manager — runs the Kindly web-search MCP via uvx
    fd
    ripgrep
    bat
    eza # Modern ls (replaces exa, which is archived)
    # zoxide is installed by programs.zoxide in bash.nix (which also wires up
    # the shell integration `z`/`zi` — it was missing entirely before).
    delta # Better git diff
    jq
    yq-go
    tldr
    htop
    btop
    ncdu # Disk usage browser
    tree

    # File management
    rsync
    p7zip
    unzip
    unrar
    aria2 # Download manager (aria2c)
    proton-drive-cli # Proton Drive from the terminal (overlays/additions.nix)
    smartmontools # smartctl — SMART health checks (internal + external disks)
    gsmartcontrol
    # Network tools
    dig
    whois
    traceroute
    ipcalc
    nmap # host/port discovery
    netcat-gnu # nc — connectivity checks / quick listeners
    tcpdump # packet capture for network debugging

    # Debug / binutils (general development)
    gdb
    binutils # objdump, strings, nm

    # Media
    spotify-player # TUI Spotify client (mirrors dotfiles `alias spotify`)

    # Fonts (additional user-level fonts)
    font-awesome

    # VPN
    openvpn

    # Web browsers
    brave
    google-chrome # CAC-authenticated DoD portals
    # Markdown Editor
    obsidian
    protonmail-bridge-gui
    thunderbird-latest
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
  # tmuxp session files — placed at ~/.config/tmuxp/
  # -----------------------------------------------------------------------
  xdg.configFile."tmuxp/dev.yaml".source = ../../tmuxp/dev.yaml;

  # -----------------------------------------------------------------------
  # Firefox — managed via programs module for profile/settings control
  # security.osclientcerts.autoload exposes OS trust anchors via p11-kit.
  # For full CAC client auth, load OpenSC manually once in Firefox:
  #   Preferences → Privacy & Security → Security Devices → Load
  #   Path: /run/current-system/sw/lib/opensc-pkcs11.so
  # -----------------------------------------------------------------------
  programs.firefox = {
    enable = true;
    configPath = ".mozilla/firefox";
    profiles.default = {
      settings = {
        "security.osclientcerts.autoload" = true;
        # Some DoD sites still require older TLS — allow TLS 1.0+
        "security.tls.version.min" = 1;
      };
    };
  };

  # -----------------------------------------------------------------------
  # fzf
  #
  # Options go through FZF_DEFAULT_OPTS_FILE (exported from bash.nix), NOT
  # programs.fzf.defaultOptions. Home Manager renders defaultOptions into the
  # FZF_DEFAULT_OPTS *session variable*, and hm-session-vars.sh self-guards with
  # __HM_SESS_VARS_SOURCED: once a graphical session has sourced it, every later
  # shell and tmux pane inherits the old value, so option changes stay invisible
  # until a full logout/login. fzf re-reads this file on every invocation, so a
  # rebuild takes effect in the next shell instead.
  #
  # QUOTING RULE: any value containing a bare `>` MUST be single-quoted, here as
  # much as in the env var. fzf parses both with a shell-words splitter that
  # honours redirection, and an unquoted `>` silently swallows the FOLLOWING
  # token — across newlines too. That is what broke Ctrl-R: the bash widget
  # inlines this file and appends `--read0`, which got eaten as a redirect
  # target, so fzf split the NUL-delimited history stream on newlines and drew
  # the entire history as a single line.
  #
  # Nix has no \u escape: write the literal glyph. "\uf054" evaluates to the
  # bare string "uf054" and fzf rejects it with "pointer display width should be
  # up to 2".
  # -----------------------------------------------------------------------
  programs.fzf = {
    enable = true;
    enableBashIntegration = true; # Ctrl-R history, Ctrl-T file, Alt-C cd
    defaultOptions = []; # deliberately empty — see xdg.configFile below
  };

  xdg.configFile."fzf/fzfrc".text = ''
    # One option per line. Blank lines and #-comments are allowed.
    # Values containing a bare `>` must be single-quoted (see packages.nix).
    --color=fg:-1,fg+:#d0d0d0,bg:-1,bg+:#262626
    --color=hl:#5fb079,hl+:#43fb00,info:#afaf87,marker:#87ff00
    --color=prompt:#06fd34,spinner:#f2ff5e,pointer:#fbfbfb,header:#87afaf
    --color=border:#2B3328,preview-fg:#f1f8f2,query:#e97b7b
    --border=rounded
    --preview-window=border-rounded
    --prompt='> '
    --marker='>'
    --pointer=
    --separator=─
    --scrollbar=│
  '';

  # -----------------------------------------------------------------------
  # Session environment (mirrors .zprofile)
  # -----------------------------------------------------------------------
  home.sessionVariables = {
    AWS_REGION = "us-east-1";
    AWS_PROFILE = "default";
    AWS_CLI_AUTO_PROMPT = "on-partial";
    DOCKER_BUILDKIT = "1";
    FZF_COMPLETION_TRIGGER = "..";
    FZF_COMPLETION_OPTS = "--border --info=inline";
  };

  # -----------------------------------------------------------------------
  # AWS config — profile definitions (no secrets, credentials via 1Password)
  # -----------------------------------------------------------------------
  home.file.".aws/config".text = ''
    [default]
    region = us-east-1
    output = json

    [profile personal]
    region = us-east-1
    output = json
  '';
}
