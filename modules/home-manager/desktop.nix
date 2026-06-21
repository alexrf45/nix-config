{ pkgs, ... }:
let
  mod   = "Mod4";
  left  = "j";
  down  = "k";
  up    = "l";
  right = "semicolon";
  term  = "kitty";
  menu  = "wofi --show drun";

  # Lock/exit mode label (mirrors the old i3 $mode_system prompt).
  systemMode = "(l)ock, (e)xit, (r)eboot, (Shift+s)hutdown";
in
{
  # -----------------------------------------------------------------------
  # Sway (Wayland) — declarative, ported from the former dotfiles/i3/config.
  # System-level session lives in modules/nixos/desktop.nix (programs.sway);
  # package = null so Home Manager only manages the user config here.
  # -----------------------------------------------------------------------
  wayland.windowManager.sway = {
    enable = true;
    package = null;

    config = {
      modifier = mod;
      terminal = term;
      menu = menu;
      floating.modifier = mod;

      fonts = {
        names = [ "JetBrains Mono" ];
        size = 10.0;
      };

      gaps = {
        inner = 4;
        outer = 2;
        smartGaps = true;
      };

      # Borderless tiling (i3 had `border pixel 0`).
      window.border = 0;
      window.titlebar = false;

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

        # media keys (Wayland-safe; no i3status refresh needed)
        "XF86AudioRaiseVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ +10%";
        "XF86AudioLowerVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ -10%";
        "XF86AudioMute"        = "exec pactl set-sink-mute @DEFAULT_SINK@ toggle";
        "XF86AudioMicMute"     = "exec pactl set-source-mute @DEFAULT_SOURCE@ toggle";
      };

      modes = {
        resize = {
          "${left}"  = "resize shrink width 10 px";
          "${down}"  = "resize grow height 10 px";
          "${up}"    = "resize shrink height 10 px";
          "${right}" = "resize grow width 10 px";
          "Left"     = "resize shrink width 10 px";
          "Down"     = "resize grow height 10 px";
          "Up"       = "resize shrink height 10 px";
          "Right"    = "resize grow width 10 px";
          "Return"   = ''mode "default"'';
          "Escape"   = ''mode "default"'';
        };
        "${systemMode}" = {
          "l"       = ''exec swaylock -i $HOME/.config/pictures/sky.png; mode "default"'';
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
        { command = "swaybg -i $HOME/.config/pictures/skull.jpg -m fill"; always = true; }
        { command = "${pkgs.waybar}/bin/waybar"; always = true; }
        { command = "kitty"; }
      ];

      # Disable swaybar — waybar is launched via startup above.
      bars = [];
    };

    # base16-bright window border colours + display/idle tweaks.
    extraConfig = ''
      # client.<state> border background text indicator child_border
      client.focused          #6fb3d2 #6fb3d2 #000000 #6fb3d2 #6fb3d2
      client.focused_inactive #303030 #303030 #e0e0e0 #303030 #303030
      client.unfocused        #000000 #000000 #b0b0b0 #000000 #000000
      client.urgent           #fb0120 #fb0120 #ffffff #fb0120 #fb0120

      # Disable screen blanking/DPMS (mirrors the old `xset s off -dpms`).
      # No swayidle is configured, so the session never auto-locks.

      # External display (the old i3 mirrored HDMI to the laptop panel).
      # Output names depend on hardware — verify with `swaymsg -t get_outputs`
      # and uncomment/adjust as needed:
      # output HDMI-A-1 mode 1920x1080 position 0,0
      # output eDP-1 position 0,0
    '';
  };

  # -----------------------------------------------------------------------
  # Waybar — config + style from dotfiles
  # -----------------------------------------------------------------------
  xdg.configFile."waybar/config".source = ../../dotfiles/waybar/config.jsonc;
  xdg.configFile."waybar/style.css".source = ../../dotfiles/waybar/style.css;

  # -----------------------------------------------------------------------
  # Wallpaper + lock screen images (referenced by swaybg / swaylock above)
  # -----------------------------------------------------------------------
  xdg.configFile."pictures/skull.jpg" = { source = ../../dotfiles/pictures/skull.jpg; force = true; };
  xdg.configFile."pictures/sky.png"   = { source = ../../dotfiles/pictures/sky.png;   force = true; };

  # -----------------------------------------------------------------------
  # mako — Wayland notification daemon (replaces dunst)
  # -----------------------------------------------------------------------
  services.mako.enable = true;

  # -----------------------------------------------------------------------
  # Desktop packages (Wayland equivalents of the former X11 toolset)
  # -----------------------------------------------------------------------
  home.packages = with pkgs; [
    waybar                 # Status bar (replaces i3blocks/i3status)
    wofi                   # App launcher (rofi replacement)
    wl-clipboard           # wl-copy / wl-paste (replaces xclip)
    wlr-randr              # Output management (replaces xrandr)
    networkmanagerapplet   # nm-applet for the tray
    pavucontrol            # PipeWire/PulseAudio GUI volume control
    brightnessctl          # Backlight/keyboard brightness
    playerctl              # Media key control (MPRIS)
    libnotify              # notify-send
  ];
}
