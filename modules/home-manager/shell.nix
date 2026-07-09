{ pkgs, config, ... }:
{
  # -----------------------------------------------------------------------
  # Zsh — mirrors .zshrc and .zsh/* from dotfiles repo
  # -----------------------------------------------------------------------
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      size = 20000;
      save = 20000;
      path = "${config.home.homeDirectory}/.zsh_history";
      extended = true;
      ignoreAllDups = true;
      ignoreSpace = true;
      share = true;
    };

    dotDir = config.home.homeDirectory;

    # Zsh options — mirrors dotfiles .zshrc setopt block
    initContent = ''
      setopt AUTO_CD
      setopt AUTO_PUSHD
      setopt EXTENDED_GLOB
      setopt EXTENDED_HISTORY
      setopt NOMATCH
      setopt MENU_COMPLETE
      setopt GLOB_DOTS
      setopt INTERACTIVE_COMMENTS
      setopt HIST_IGNORE_DUPS
      setopt HIST_VERIFY
      setopt INC_APPEND_HISTORY
      setopt SHARE_HISTORY
      setopt PROMPT_SUBST
      unsetopt beep
      setopt HIST_IGNORE_SPACE

      # Completion styling
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
      zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
      zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
      zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

      # Autosuggestion styling
      ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#ffffff,standout"
      ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE="10"
      ZSH_AUTOSUGGEST_USE_ASYNC=1

      # Edit command in $EDITOR
      autoload -Uz edit-command-line
      zle -N edit-command-line
      bindkey '^X^E' edit-command-line

      # Source all modular zsh files (mirrors `for file in $HOME/.zsh/*; do source $file; done`)
      for file in $HOME/.zsh/*.zsh; do
        source "$file"
      done

      # Auto-activate Python virtualenv on directory change
      autoload -Uz add-zsh-hook
      add-zsh-hook chpwd auto_venv
    '';
  };

  # -----------------------------------------------------------------------
  # Starship prompt — replaces dracula theme from dotfiles
  # -----------------------------------------------------------------------
  programs.starship = {
    enable = true;
    # Config is managed via xdg.configFile."starship.toml" (see below)
    enableZshIntegration = true;
  };

  # -----------------------------------------------------------------------
  # Modular zsh config files — mirrors .zsh/*.zsh from dotfiles
  # Placed at ~/.zsh/*.zsh and sourced from initExtra above
  # -----------------------------------------------------------------------
  home.file = {
    ".zsh/aliases.zsh".source   = ../../dotfiles/zsh/aliases.zsh;
    ".zsh/git.zsh".source       = ../../dotfiles/zsh/git.zsh;
    ".zsh/docker.zsh".source    = ../../dotfiles/zsh/docker.zsh;
    ".zsh/aws.zsh".source       = ../../dotfiles/zsh/aws.zsh;
    ".zsh/tf.zsh".source        = ../../dotfiles/zsh/tf.zsh;
    ".zsh/python.zsh".source    = ../../dotfiles/zsh/python.zsh;
    ".zsh/history.zsh".source   = ../../dotfiles/zsh/history.zsh;
    ".zsh/functions.zsh".source = ../../dotfiles/zsh/functions.zsh;

    # Overwrite the pre-NixOS dotfiles .zprofile — it contained a multiline
    # FZF_DEFAULT_OPTS with bare > characters that zsh interpreted as redirects,
    # creating junk files in $HOME on every login. Session variables are now
    # managed by Home Manager via home.sessionVariables / programs.fzf.
    ".zprofile" = { text = "# Managed by Home Manager — do not edit\n"; force = true; };
  };
}
