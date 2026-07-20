{...}: {
  # -----------------------------------------------------------------------
  # kitty — GPU terminal, flow.nvim moon-umbra palette (pink fluo accent)
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

      # flow.nvim moon-umbra (dark, pink fluo accent)
      background = "#1f282e";
      foreground = "#94aab8";

      cursor = "#ff007b";
      cursor_text_color = "#0d0d0d";

      selection_background = "#0d0d0d";
      selection_foreground = "#ff007b";

      # normal
      color0 = "#0d0d0d"; # black
      color1 = "#862d34"; # red
      color2 = "#34862d"; # green
      color3 = "#86862d"; # yellow
      color4 = "#2d6186"; # blue
      color5 = "#592d86"; # magenta
      color6 = "#2d8670"; # cyan
      color7 = "#f2f2f2"; # white

      # bright
      color8 = "#3b4d59"; # bright black
      color9 = "#862d34"; # bright red
      color10 = "#34862d"; # bright green
      color11 = "#86862d"; # bright yellow
      color12 = "#2d6186"; # bright blue
      color13 = "#592d86"; # bright magenta
      color14 = "#2d8670"; # bright cyan
      color15 = "#f2f2f2"; # bright white
    };
  };
}
