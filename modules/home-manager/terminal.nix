{ pkgs, ... }:
{
  # -----------------------------------------------------------------------
  # Alacritty — mirrors .config/alacritty/ from dotfiles
  # -----------------------------------------------------------------------
  programs.alacritty = {
    enable = true;
    settings = {
      general.live_config_reload = true;

      env = {
        TERM = "xterm-256color";
      };

      window = {
        startup_mode = "Maximized";
        decorations = "None";
        dynamic_padding = true;
        padding = { x = 4; y = 4; };
      };

      font = {
        normal = {
          family = "Iosevka Nerd Font Mono";
          style = "Regular";
        };
        bold = {
          family = "Iosevka Nerd Font Mono";
          style = "Bold";
        };
        italic = {
          family = "Iosevka Nerd Font Mono";
          style = "Italic";
        };
        size = 11.0;
      };

      scrolling = {
        history = 20000;
        multiplier = 3;
      };

      selection.save_to_clipboard = true;

      # Vi mode keybindings
      keyboard.bindings = [
        { key = "V"; mods = "Control|Shift"; action = "Paste"; }
        { key = "C"; mods = "Control|Shift"; action = "Copy"; }
        { key = "Return"; mods = "Control|Shift"; action = "SpawnNewInstance"; }
      ];
    };
  };
}
