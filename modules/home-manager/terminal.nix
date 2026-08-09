{...}: {
  # -----------------------------------------------------------------------
  # kitty — GPU terminal, cendre palette (github.com/Aejkatappaja/cendre)
  # Lifted verbatim from the theme's shipped extras/kitty/cendre-soft.conf (soft variant)
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

      # cendre (soft, dark-only)
      background = "#231f1d";
      foreground = "#e6d5c2";

      cursor = "#ea9875";
      cursor_text_color = "#231f1d";
      url_color = "#4e89a2";

      selection_background = "#3d2b23";
      selection_foreground = "#e6d5c2";

      # normal
      color0 = "#2d2725"; # black
      color1 = "#d1766e"; # red
      color2 = "#99af6b"; # green
      color3 = "#fcba81"; # yellow
      color4 = "#58bdff"; # blue
      color5 = "#9480ba"; # magenta
      color6 = "#4e89a2"; # cyan
      color7 = "#a09384"; # white

      # bright
      color8 = "#73665b"; # bright black
      color9 = "#d25780"; # bright red
      color10 = "#43b16a"; # bright green
      color11 = "#f4a21c"; # bright yellow
      color12 = "#8bcfff"; # bright blue
      color13 = "#a692cd"; # bright magenta
      color14 = "#20c9cb"; # bright cyan
      color15 = "#e6d5c2"; # bright white

      active_tab_foreground = "#e6d5c2";
      active_tab_background = "#231f1d";
      inactive_tab_foreground = "#73665b";
      inactive_tab_background = "#1a1716";
      active_border_color = "#ea9875";
      inactive_border_color = "#443c39";
      bell_border_color = "#f4a21c";
    };
  };
}
