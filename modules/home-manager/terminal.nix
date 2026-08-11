{...}: {
  # -----------------------------------------------------------------------
  # kitty — GPU terminal, peace palette (from dotfiles/pictures/peace.png).
  # Mural-derived: saffron/gold/crimson/indigo/jade/teal/lotus on pure black.
  # -----------------------------------------------------------------------
  programs.kitty = {
    enable = true;

    font = {
      name = "UbuntuMono Nerd Font Regular";
      size = 14;
    };

    settings = {
      scrollback_lines = 20000;
      copy_on_select = "clipboard";
      window_padding_width = 4;
      hide_window_decorations = "yes";
      confirm_os_window_close = 0;
      enable_audio_bell = "no";

      # peace (mural-derived, pure-black bg)
      background = "#000000";
      foreground = "#ede0c8";

      cursor = "#f2a93b";
      cursor_text_color = "#000000";
      url_color = "#3aafb9";

      selection_background = "#2a2018";
      selection_foreground = "#ede0c8";

      # normal
      color0 = "#1a1512"; # black
      color1 = "#c6362f"; # red
      color2 = "#5aa469"; # green
      color3 = "#f2a93b"; # yellow
      color4 = "#4a74d0"; # blue
      color5 = "#b0568a"; # magenta
      color6 = "#3aafb9"; # cyan
      color7 = "#c9b99c"; # white

      # bright
      color8 = "#6b5d4f"; # bright black
      color9 = "#e05a4e"; # bright red
      color10 = "#7cc088"; # bright green
      color11 = "#f4c430"; # bright yellow
      color12 = "#6f95ff"; # bright blue
      color13 = "#e890a8"; # bright magenta
      color14 = "#5fd0d6"; # bright cyan
      color15 = "#f5ecdb"; # bright white

      active_tab_foreground = "#ede0c8";
      active_tab_background = "#000000";
      inactive_tab_foreground = "#6b5d4f";
      inactive_tab_background = "#0d0b0a";
      active_border_color = "#f2a93b";
      inactive_border_color = "#3a322c";
      bell_border_color = "#f4c430";
    };
  };
}
