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
  # Any option value containing a bare `>` MUST be single-quoted. Home Manager
  # joins defaultOptions into the FZF_DEFAULT_OPTS env var, and fzf parses that
  # with a shell-words splitter that honours redirection — an unquoted `>` is
  # read as a redirect operator and silently swallows the NEXT token. That broke
  # Ctrl-R: the bash widget appends `--read0`, which got eaten as the redirect
  # target, so fzf split the NUL-delimited history on newlines instead and
  # rendered the entire history as one line.
  #
  # Note Nix has no \u escape — a literal glyph must be written out, not
  # "\uf054" (which evaluates to the bare string "uf054" and makes fzf exit 2
  # with "pointer display width should be up to 2").
  # -----------------------------------------------------------------------
  programs.fzf = {
    enable = true;
    enableBashIntegration = true; # Ctrl-R history, Ctrl-T file, Alt-C cd
    defaultOptions = [
      "--color=fg:-1,fg+:#d0d0d0,bg:-1,bg+:#262626"
      "--color=hl:#5fb079,hl+:#43fb00,info:#afaf87,marker:#87ff00"
      "--color=prompt:#06fd34,spinner:#f2ff5e,pointer:#fbfbfb,header:#87afaf"
      "--color=border:#2B3328,preview-fg:#f1f8f2,query:#e97b7b"
      "--border=rounded"
      "--preview-window=border-rounded"
      "--prompt='> '"
      "--marker='>'"
      "--pointer="
      "--separator=─"
      "--scrollbar=│"
    ];
  };

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
