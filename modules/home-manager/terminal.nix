{...}: {
  # -----------------------------------------------------------------------
  # kitty — GPU terminal, guts palette (github.com/vossenwout/guts.nvim)
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

      # guts (dark) — from extras/ghostty/guts upstream
      background = "#101113";
      foreground = "#9f9e99";

      cursor = "#9f9e99";
      url_color = "#697a9a";

      selection_background = "#4a4253";
      selection_foreground = "#e1ffe5";

      # normal
      color0 = "#101113"; # black
      color1 = "#93554b"; # red
      color2 = "#51606a"; # green
      color3 = "#ac7f7b"; # yellow
      color4 = "#697a9a"; # blue
      color5 = "#83799c"; # magenta
      color6 = "#7a837c"; # cyan
      color7 = "#9f9e99"; # white

      # bright
      color8 = "#4a4253"; # bright black
      color9 = "#93554b"; # bright red
      color10 = "#a7d8b0"; # bright green
      color11 = "#e1ffe5"; # bright yellow
      color12 = "#8288a0"; # bright blue
      color13 = "#997e95"; # bright magenta
      color14 = "#879493"; # bright cyan
      color15 = "#a8a7a2"; # bright white

      active_tab_foreground = "#101113";
      active_tab_background = "#697a9a";
      inactive_tab_foreground = "#9f9e99";
      inactive_tab_background = "#161719";
      active_border_color = "#697a9a";
      inactive_border_color = "#161719";
    };
  };
}
