{ pkgs, lib, ... }:
{
  # -----------------------------------------------------------------------
  # Emacs + Doom Emacs
  # programs.emacs installs the binary and native-compiled modules.
  # Doom itself lives at ~/.config/emacs (cloned once manually).
  # Doom config is sourced from dotfiles/doom/ via xdg.configFile below.
  # To install doom for the first time:
  #   git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
  #   ~/.config/emacs/bin/doom install
  # To update doom packages after editing dotfiles/doom/:
  #   doom sync
  # -----------------------------------------------------------------------
  programs.emacs = {
    enable = true;
    # emacs30 (GTK3) works on both horus (Wayland/Sway via XWayland) and
    # thoth (X11/i3). Override to emacs30-pgtk on horus for native Wayland
    # if desired, via the host-specific home-manager entry.
    package = pkgs.emacs30;
    extraPackages = epkgs: with epkgs; [
      vterm   # requires native shared library; must be declared here
    ];
  };

  # System-level tools LSP modules and plugins need at runtime.
  # ripgrep/fd are already in packages.nix; listed here as documentation only.
  home.packages = with pkgs; [
    # Language servers (on PATH — doom's lsp-mode picks them up automatically)
    lua-language-server
    gopls
    pyright
    terraform-ls
    yaml-language-server
    typescript-language-server
    bash-language-server

    # Build tooling (treesitter native compilation, LSP deps)
    gcc
    nodejs

    # org-roam hard dependency
    sqlite

    # Doom doctor / doom env needs these
    gnutls
    imagemagick
  ];

  # Doom config directory — symlinked from dotfiles/doom/
  # Edit dotfiles/doom/{init,config,packages}.el then run `doom sync`.
  xdg.configFile."doom" = {
    source = ../../dotfiles/doom;
    recursive = true;
    force = true;
  };

  # Run `doom sync` automatically after each home-manager activation.
  # Guarded so it's a no-op until doom is installed for the first time.
  home.activation.doomSync = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ -x "$HOME/.config/emacs/bin/doom" ]; then
      "$HOME/.config/emacs/bin/doom" sync -e 2>&1 | tail -5 || true
    fi
  '';

  # Put doom's bin on PATH so `doom` is usable from any shell
  home.sessionPath = [ "$HOME/.config/emacs/bin" ];
}
