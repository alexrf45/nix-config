{...}: {
  # -----------------------------------------------------------------------
  # kitty — GPU terminal, luna palette (WTFox/luna.nvim).
  # Near-black base (#060606) with four muted accents — warm keyword,
  # cool func-blue, plum type, sage string — matching the neovim luna theme.
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

      # luna (near-black bg)
      background = "#060606";
      foreground = "#e4e4e8";

      cursor = "#c2916a";
      cursor_text_color = "#060606";
      url_color = "#75a1c7";

      selection_background = "#384048";
      selection_foreground = "#e4e4e8";

      # normal
      color0 = "#000000"; # black
      color1 = "#e08585"; # red      (error)
      color2 = "#6fbe80"; # green    (ok)
      color3 = "#c2916a"; # yellow   (signal)
      color4 = "#75a1c7"; # blue     (func)
      color5 = "#c4a8d6"; # magenta  (type)
      color6 = "#75a1c7"; # cyan     (func)
      color7 = "#c7c7c7"; # white    (silver)

      # bright
      color8 = "#888888"; # bright black   (grey)
      color9 = "#e08585"; # bright red     (error)
      color10 = "#6fbe80"; # bright green   (ok)
      color11 = "#d9a35a"; # bright yellow  (warning)
      color12 = "#8c9cb8"; # bright blue    (info)
      color13 = "#c4a8d6"; # bright magenta (type)
      color14 = "#75a1c7"; # bright cyan    (func)
      color15 = "#ffffff"; # bright white   (white)

      active_tab_foreground = "#e4e4e8";
      active_tab_background = "#060606";
      inactive_tab_foreground = "#7c7c7c";
      inactive_tab_background = "#1c1c1c";
      active_border_color = "#c2916a";
      inactive_border_color = "#404040";
      bell_border_color = "#d9a35a";
    };
  };
}
