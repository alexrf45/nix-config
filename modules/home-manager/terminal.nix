{...}: {
  # -----------------------------------------------------------------------
  # kitty — GPU terminal, moonfly palette (github.com/bluz71/vim-moonfly-colors)
  # -----------------------------------------------------------------------
  programs.kitty = {
    enable = true;

    font = {
      name = "Iosevka Nerd Font Mono";
      size = 14;
    };

    settings = {
      scrollback_lines = 20000;
      copy_on_select = "clipboard";
      window_padding_width = 4;
      hide_window_decorations = "yes";
      confirm_os_window_close = 0;
      enable_audio_bell = "no";

      # moonfly (dark)
      background = "#080808";
      foreground = "#bdbdbd";

      cursor = "#9e9e9e";
      url_color = "#79dac8";

      selection_background = "#b2ceee";
      selection_foreground = "#080808";

      # normal
      color0 = "#323437"; # black
      color1 = "#ff5d5d"; # red
      color2 = "#8cc85f"; # green
      color3 = "#e3c78a"; # yellow
      color4 = "#80a0ff"; # blue
      color5 = "#cf87e8"; # magenta
      color6 = "#79dac8"; # cyan
      color7 = "#c6c6c6"; # white

      # bright
      color8 = "#949494"; # bright black
      color9 = "#ff5189"; # bright red
      color10 = "#36c692"; # bright green
      color11 = "#c6c684"; # bright yellow
      color12 = "#74b2ff"; # bright blue
      color13 = "#ae81ff"; # bright magenta
      color14 = "#85dc85"; # bright cyan
      color15 = "#e4e4e4"; # bright white

      active_tab_foreground = "#080808";
      active_tab_background = "#80a0ff";
      inactive_tab_foreground = "#b2b2b2";
      inactive_tab_background = "#323437";
      active_border_color = "#80a0ff";
      inactive_border_color = "#323437";
    };
  };
}
