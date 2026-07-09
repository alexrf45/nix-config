{ ... }:
{
  # -----------------------------------------------------------------------
  # kitty — GPU terminal, gruvbox-material dark soft palette
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

      # gruvbox-material dark soft
      background = "#32302f";
      foreground = "#d4be98";

      cursor            = "#d4be98";
      cursor_text_color = "#32302f";

      selection_background = "#45403d";
      selection_foreground = "#d4be98";

      # normal
      color0 = "#665c54";  # black
      color1 = "#ea6962";  # red
      color2 = "#a9b665";  # green
      color3 = "#d8a657";  # yellow
      color4 = "#7daea3";  # blue
      color5 = "#d3869b";  # magenta
      color6 = "#89b482";  # cyan
      color7 = "#d4be98";  # white

      # bright
      color8  = "#928374";  # bright black
      color9  = "#ea6962";  # bright red
      color10 = "#a9b665";  # bright green
      color11 = "#d8a657";  # bright yellow
      color12 = "#7daea3";  # bright blue
      color13 = "#d3869b";  # bright magenta
      color14 = "#89b482";  # bright cyan
      color15 = "#d4be98";  # bright white
    };
  };
}
