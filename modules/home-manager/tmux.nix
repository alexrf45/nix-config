{ pkgs, config, ... }:
{
  # -----------------------------------------------------------------------
  # Tmux — mirrors .tmux.conf from dotfiles
  # tpm is bootstrapped by the conf itself (git clone on first run)
  # -----------------------------------------------------------------------
  programs.tmux = {
    enable = true;
    shell = "${pkgs.zsh}/bin/zsh";

    # The full tmux config mirrors the dotfiles .tmux.conf exactly.
    # tpm bootstrap: if ~/.tmux/plugins/tpm doesn't exist, git-clones it.
    extraConfig = ''
      set -g default-command "${pkgs.zsh}/bin/zsh"

      unbind C-b
      set -g prefix C-Space
      bind C-Space send-prefix

      set -g set-clipboard on
      set -g visual-activity off
      set -gq allow-passthrough on

      bind t set-option status

      set-window-option -g automatic-rename on
      set-option -g automatic-rename-format '#{b:pane_current_path}'
      set-option -g set-titles on

      set -g default-terminal "tmux-256color"
      set -ga terminal-overrides ',xterm-256color:RGB'

      set -g status-keys vi
      setw -g mode-keys vi
      set -g mouse on
      set -g renumber-windows on
      set -g base-index 1
      setw -g pane-base-index 1

      bind S command-prompt 'rename-session %%'
      bind N new-session

      unbind n
      unbind p

      bind s split-window -v -c "#{pane_current_path}"
      bind v split-window -h -c "#{pane_current_path}"
      unbind '"'
      unbind %

      set-window-option -g mode-keys vi
      bind-key h select-pane -L
      bind-key j select-pane -D
      bind-key k select-pane -U
      bind-key l select-pane -R

      bind c new-window
      bind < resize-pane -L 10
      bind > resize-pane -R 10
      bind + resize-pane -D 10
      bind - resize-pane -U 10

      set -sg escape-time 0
      set-option -g focus-events on
      bind-key x kill-pane
      set -g detach-on-destroy off

      bind r source-file ~/.tmux.conf \; display "Reloaded!"

      set -g status-right " "
      set -g status-left "%H:%M:%S - "
      set -g status-style "fg=white,bg=default"
      set -g status-right-length 200
      set -g status-left-length 100
      set -g status-justify left
      set -g status-position top
      set -g status-interval 1

      set -g @plugin 'tmux-plugins/tpm'
      set -g @plugin 'tmux-plugins/tmux-sensible'
      set -g @plugin 'tmux-plugins/tmux-continuum'
      set -g @continuum-restore 'on'
      set -g @plugin 'tmux-plugins/tmux-logging'
      set -g @plugin 'sainnhe/tmux-fzf'
      set -g @logging-path "$HOME/.logs"

      if "test ! -d ~/.tmux/plugins/tpm" \
         "run 'git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm && ~/.tmux/plugins/tpm/bin/install_plugins'"

      run '~/.tmux/plugins/tpm/tpm'
    '';
  };
}
