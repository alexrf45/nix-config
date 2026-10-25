{...}: {
  # -----------------------------------------------------------------------
  # kitty — GPU terminal, posterpole palette (github.com/ilof2/posterpole.nvim),
  # matching the neovim posterpole theme.
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

      # posterpole (dark) — from posterpole/kitty themes/posterpole.conf upstream
      background = "#24212a";
      foreground = "#aea79c";

      cursor = "#afb19d";
      cursor_text_color = "#24212a";
      url_color = "#6c7f93";

      selection_background = "#4d4d4d";
      selection_foreground = "#afa79d";

      # normal
      color0 = "#2c2c30"; # black
      color1 = "#a97070"; # red
      color2 = "#778c73"; # green
      color3 = "#cc9166"; # yellow
      color4 = "#6c7f93"; # blue
      color5 = "#b894af"; # magenta
      color6 = "#8ea4a2"; # cyan
      color7 = "#afa79d"; # white

      # bright
      color8 = "#a5a59c"; # bright black
      color9 = "#bc8f8f"; # bright red
      color10 = "#92a38f"; # bright green
      color11 = "#d9ac8c"; # bright yellow
      color12 = "#8a99a8"; # bright blue
      color13 = "#ccb3c6"; # bright magenta
      color14 = "#8fa4a2"; # bright cyan
      color15 = "#c6c0b9"; # bright white

      active_tab_foreground = "#24212a";
      active_tab_background = "#6c7f93";
      inactive_tab_foreground = "#aea79c";
      inactive_tab_background = "#2c2c30";
      active_border_color = "#6c7f93";
      inactive_border_color = "#2c2c30";
      bell_border_color = "#cc9166";
    };
  };
}
