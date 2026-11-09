{ pkgs, ... }:
let
  # Keys mirror desktop-i3.nix so muscle memory carries across sessions.
  mod   = "Mod4";
  left  = "j";
  down  = "k";
  up    = "l";
  right = "semicolon";
  term  = "kitty";
  menu  = "dms ipc call spotlight toggle"; # Dux launcher (replaces rofi)

  systemMode = "(l)ock, (e)xit, (r)eboot, (Shift+s)hutdown";
in
{
  # Sway + Dux Shell; system side in modules/nixos/desktop.nix + dux.nix.
  wayland.windowManager.sway = {
    enable = true;
    package = null;

    config = {
      modifier = mod;
      terminal = term;
      menu = menu;
      floating.modifier = mod;

      fonts = {
        names = [ "Iosevka Nerd Font" ];
        size = 10.0;
      };

      gaps = {
        inner = 8;
        outer = 4;
        smartGaps = true;
      };

      window.border = 2;
      window.titlebar = false;

      # Dux opens its own windows (settings etc.) floating.
      window.commands = [
        { criteria.app_id = "dev.duxlabs.shell"; command = "floating enable"; }
      ];

      keybindings = {
        "${mod}+Return" = "exec ${term}";
        "${mod}+q"      = "kill";
        "${mod}+d"      = "exec ${menu}";

        # focus (vim keys + arrows)
        "${mod}+${left}"  = "focus left";
        "${mod}+${down}"  = "focus down";
        "${mod}+${up}"    = "focus up";
        "${mod}+${right}" = "focus right";
        "${mod}+Left"     = "focus left";
        "${mod}+Down"     = "focus down";
        "${mod}+Up"       = "focus up";
        "${mod}+Right"    = "focus right";

        # move
        "${mod}+Shift+${left}"  = "move left";
        "${mod}+Shift+${down}"  = "move down";
        "${mod}+Shift+${up}"    = "move up";
        "${mod}+Shift+${right}" = "move right";
        "${mod}+Shift+Left"     = "move left";
        "${mod}+Shift+Down"     = "move down";
        "${mod}+Shift+Up"       = "move up";
        "${mod}+Shift+Right"    = "move right";

        # layout
        "${mod}+minus"       = "split h";
        "${mod}+backslash"   = "split v";
        "${mod}+f"           = "fullscreen toggle";
        "${mod}+s"           = "layout stacking";
        "${mod}+w"           = "layout tabbed";
        "${mod}+e"           = "layout toggle split";
        "${mod}+Shift+space" = "floating toggle";
        "${mod}+space"       = "focus mode_toggle";
        "${mod}+a"           = "focus parent";

        # workspaces
        "${mod}+1" = "workspace number 1";
        "${mod}+2" = "workspace number 2";
        "${mod}+3" = "workspace number 3";
        "${mod}+4" = "workspace number 4";
        "${mod}+5" = "workspace number 5";
        "${mod}+6" = "workspace number 6";
        "${mod}+Shift+1" = "move container to workspace number 1";
        "${mod}+Shift+2" = "move container to workspace number 2";
        "${mod}+Shift+3" = "move container to workspace number 3";
        "${mod}+Shift+4" = "move container to workspace number 4";
        "${mod}+Shift+5" = "move container to workspace number 5";
        "${mod}+Shift+6" = "move container to workspace number 6";

        # session control (sway has no in-place restart; reload covers both)
        "${mod}+Shift+c" = "reload";
        "${mod}+Shift+r" = "reload";

        # modes
        "${mod}+r" = ''mode "resize"'';
        "${mod}+0" = ''mode "${systemMode}"'';

        # screenshot (flameshot gui -> grim + slurp region to clipboard)
        "${mod}+p" = ''exec grim -g "$(slurp)" - | wl-copy'';

        # media / brightness keys
        "XF86AudioRaiseVolume"  = "exec pactl set-sink-volume @DEFAULT_SINK@ +10%";
        "XF86AudioLowerVolume"  = "exec pactl set-sink-volume @DEFAULT_SINK@ -10%";
        "XF86AudioMute"         = "exec pactl set-sink-mute @DEFAULT_SINK@ toggle";
        "XF86AudioMicMute"      = "exec pactl set-source-mute @DEFAULT_SOURCE@ toggle";
        "XF86MonBrightnessUp"   = "exec brightnessctl set +10%";
        "XF86MonBrightnessDown" = "exec brightnessctl set 10%-";
      };

      modes = {
        resize = {
          "${left}"  = "resize shrink width 10 px or 10 ppt";
          "${down}"  = "resize grow height 10 px or 10 ppt";
          "${up}"    = "resize shrink height 10 px or 10 ppt";
          "${right}" = "resize grow width 10 px or 10 ppt";
          "Left"     = "resize shrink width 10 px or 10 ppt";
          "Down"     = "resize grow height 10 px or 10 ppt";
          "Up"       = "resize shrink height 10 px or 10 ppt";
          "Right"    = "resize grow width 10 px or 10 ppt";
          "Return"   = ''mode "default"'';
          "Escape"   = ''mode "default"'';
          "${mod}+r" = ''mode "default"'';
        };
        "${systemMode}" = {
          "l"       = ''exec dms ipc call lock lock; mode "default"'';
          "e"       = ''exec swaymsg exit; mode "default"'';
          "r"       = ''exec systemctl reboot; mode "default"'';
          "Shift+s" = ''exec systemctl poweroff; mode "default"'';
          "Return"  = ''mode "default"'';
          "Escape"  = ''mode "default"'';
        };
      };

      # Send kitty to workspace 1 (app_id is the Wayland-native class).
      assigns = {
        "1" = [{ app_id = "kitty"; }];
      };

      startup = [
        { command = "kitty"; }
      ];

      # Dux Shell (dms.service, started by sway-session.target) draws the bar and wallpaper.
      bars = [];
    };

    # base16-bright window border colours + display/idle tweaks.
    extraConfig = ''
      # client.<state> border background text indicator child_border
      client.focused          #6fb3d2 #6fb3d2 #000000 #6fb3d2 #6fb3d2
      client.focused_inactive #303030 #303030 #e0e0e0 #303030 #303030
      client.unfocused        #000000 #000000 #b0b0b0 #000000 #000000
      client.urgent           #fb0120 #fb0120 #ffffff #fb0120 #fb0120

      # External display: names differ from X11 (HDMI-A-1 vs HDMI-1) — check
      # `swaymsg -t get_outputs` and uncomment/adjust as needed:
      # output HDMI-A-1 mode 1920x1080 position 0,0
      # output eDP-1 position 0,0
    '';
  };

  home.packages = with pkgs; [
    wlr-randr # Output management (replaces xrandr)
  ];
}
