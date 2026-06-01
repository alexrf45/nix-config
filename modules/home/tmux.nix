# tmux — ported from resources/tmux.conf. Native home-manager options cover the
# common settings; the key bindings and the engagement status bar (session,
# VPN tun0 IP, clock) are carried over verbatim in extraConfig.
{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    prefix = "C-a";
    baseIndex = 1;
    escapeTime = 0;
    historyLimit = 20000;
    keyMode = "vi";
    mouse = true;
    terminal = "tmux-256color";
    plugins = [ pkgs.tmuxPlugins.sensible ];

    extraConfig = ''
      set -g default-command ${pkgs.zsh}/bin/zsh
      bind C-a send-prefix

      # toggle status bar
      bind t set-option status

      set-window-option -g automatic-rename on
      set-option -g set-titles on
      set-option -ga terminal-overrides ",xterm-256color:Tc"

      set -g renumber-windows on
      setw -g pane-base-index 1

      # split panes, keeping cwd
      bind g split-window -h -c "#{pane_current_path}"
      bind h split-window -v -c "#{pane_current_path}"
      unbind '"'
      unbind %
      bind c new-window -c "#{pane_current_path}"

      # swap / join windows
      bind -r "<" swap-window -d -t -1
      bind -r ">" swap-window -d -t +1
      bind j choose-window 'join-pane -h -s "%%"'
      bind J choose-window 'join-pane -s "%%"'

      bind r source-file ~/.tmux.conf \; display "Reloaded!"

      # status bar
      set -g window-status-style 'fg=#665c54'
      set -g status-style default
      set -g status-right-length 100
      set -g status-right ' '
      set -g status-left-length 150
      set -g status-left "#[fg=default]Session: #[fg=green]#S #[fg=default]VPN: #[fg=red]#(ip a | grep tun0 | cut -d ' ' -f 6 | grep -v 'qdisc')  #[fg=white]Local Time/Date: #[fg=green]%a %d %b %Y %T "
      set -g status-justify left
      set -g status-position top
      set -g status-interval 1

      setw -g monitor-activity off
      set -g visual-activity off
    '';
  };
}
