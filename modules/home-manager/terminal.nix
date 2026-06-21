{ ... }:
{
  # -----------------------------------------------------------------------
  # kitty — GPU terminal, base16-bright palette
  # -----------------------------------------------------------------------
  programs.kitty = {
    enable = true;

    font = {
      name = "Iosevka Nerd Font Mono";
      size = 11;
    };

    settings = {
      scrollback_lines = 20000;
      copy_on_select = "clipboard";
      window_padding_width = 4;
      hide_window_decorations = "yes";
      confirm_os_window_close = 0;
      enable_audio_bell = "no";

      # base16-bright (Chris Kempson) — terminal mapping
      background = "#000000";  # base00
      foreground = "#e0e0e0";  # base05

      cursor            = "#e0e0e0";  # base05
      cursor_text_color = "#000000";  # base00

      selection_background = "#505050";  # base02
      selection_foreground = "#e0e0e0";  # base05

      # normal
      color0 = "#000000";  # base00 black
      color1 = "#fb0120";  # base08 red
      color2 = "#a1c659";  # base0B green
      color3 = "#fda331";  # base0A yellow
      color4 = "#6fb3d2";  # base0D blue
      color5 = "#d381c3";  # base0E magenta
      color6 = "#76c7b7";  # base0C cyan
      color7 = "#e0e0e0";  # base05 white

      # bright
      color8  = "#b0b0b0";  # base03
      color9  = "#fb0120";  # base08
      color10 = "#a1c659";  # base0B
      color11 = "#fda331";  # base0A
      color12 = "#6fb3d2";  # base0D
      color13 = "#d381c3";  # base0E
      color14 = "#76c7b7";  # base0C
      color15 = "#ffffff";  # base07
    };
  };
}
