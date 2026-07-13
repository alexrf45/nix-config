{ pkgs, ... }:
let
  mod   = "Mod4";
  # vim-style focus keys, matching the Debian i3 config
  up    = "l";
  down  = "k";
  left  = "j";
  right = "semicolon";
  term  = "kitty";
  rofiRun = "rofi -combi-modi window#drun -show combi -modi combi -show-icons";
  rofiWin = "rofi -show window";
  refresh = "killall -SIGUSR1 i3status";

  systemMode = "(l)ock, (e)xit, (r)eboot, (Shift+s)hutdown";
in
{
  # -----------------------------------------------------------------------
  # i3 (X11) — faithful port of ~/.config/i3/config from the Debian setup.
  # System-level i3/lightdm bits live in modules/nixos/desktop-x11.nix.
  # -----------------------------------------------------------------------
  xsession.windowManager.i3 = {
    enable = true;

    config = {
      modifier = mod;
      terminal = term;
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

      window.border = 0;

      keybindings = {
        "${mod}+Return" = "exec ${term}";
        "${mod}+q"      = "kill";

        "${mod}+d" = "exec --no-startup-id ${rofiRun}";
        "${mod}+g" = "exec --no-startup-id ${rofiWin}";

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

        # workspaces (1-6)
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

        # reload / restart (i3 supports true in-place restart on X11)
        "${mod}+Shift+c" = "reload";
        "${mod}+Shift+r" = "restart";

        # modes
        "${mod}+r" = ''mode "resize"'';
        "${mod}+0" = ''mode "${systemMode}"'';

        # screenshot
        "${mod}+p" = "exec --no-startup-id flameshot gui";

        # media keys (refresh i3status after each change)
        "XF86AudioRaiseVolume" = "exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ +10% && ${refresh}";
        "XF86AudioLowerVolume" = "exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ -10% && ${refresh}";
        "XF86AudioMute"        = "exec --no-startup-id pactl set-sink-mute @DEFAULT_SINK@ toggle && ${refresh}";
        "XF86AudioMicMute"     = "exec --no-startup-id pactl set-source-mute @DEFAULT_SOURCE@ toggle && ${refresh}";
        "XF86MonBrightnessUp"   = "exec --no-startup-id brightnessctl set +10%";
        "XF86MonBrightnessDown" = "exec --no-startup-id brightnessctl set 10%-";
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
          "l"       = ''exec --no-startup-id i3lock -i "$HOME/.config/pictures/sky.png", mode "default"'';
          "e"       = ''exec --no-startup-id i3-msg exit, mode "default"'';
          "r"       = ''exec --no-startup-id systemctl reboot, mode "default"'';
          "Shift+s" = ''exec --no-startup-id systemctl poweroff, mode "default"'';
          "Return"  = ''mode "default"'';
          "Escape"  = ''mode "default"'';
        };
      };

      # Send kitty to ws1 and Brave to ws2 (X11 window classes).
      assigns = {
        "1" = [{ class = "kitty"; }];
        "2" = [{ class = "brave-browser"; }];
      };

      startup = [
        { command = "feh --no-fehbg --bg-fill $HOME/.config/pictures/dark-waves.jpg"; always = true; notification = false; }
        { command = "picom --config ~/.config/picom.conf -b"; always = true; notification = false; }
        { command = "i3-msg 'workspace 1; exec kitty'"; notification = false; }
        { command = "i3-msg 'workspace 2; exec brave'"; notification = false; }
      ];

      # Custom bar defined in extraConfig below.
      bars = [ ];
    };

    # i3bar + i3status, client colours, and display tweaks — verbatim from the
    # Debian config (client.* uses the original 4-field form).
    extraConfig = ''
      bar {
         position top
         mode hide
         font pango:UbuntuMono Nerd Font 10
         height 17
         tray_output none
         i3bar_command i3bar --transparency
         status_command i3status -c ~/.config/i3/i3status.conf
         colors {
                statusline #e0e0e0
                background #32302f
                focused_workspace #81a2be #000000 #81a2be
               }
        }

      client.focused          #010202 #010202 #FFFFFF #00DA8E
      client.focused_inactive #333333 #5F676A #ffffff #484e50
      client.unfocused        #333333 #424242 #888888 #292d2e
      client.urgent           #C10004 #900000 #ffffff #900000

      # Disable screen blanking / DPMS (mirrors the old `xset s off -dpms`).
      exec_always --no-startup-id xset s off
      exec_always --no-startup-id xset -dpms
      exec_always --no-startup-id xset s noblank

      # External monitor as primary; laptop panel off when connected.
      # Verify output names with `xrandr` — adjust HDMI-1 if yours differs (e.g. HDMI-2, DP-1).
      exec_always --no-startup-id xrandr --output HDMI-1 --auto --primary --output eDP-1 --off
      workspace 1 output HDMI-1
    '';
  };

  # i3status config file (referenced by the bar's status_command above).
  xdg.configFile."i3/i3status.conf".text = ''
    # i3status — drives the i3bar for the thoth X11 session.
    general {
            colors = true
            markup = "pango"
            interval = 5
            color_good = "#a1c659"
            color_bad = "#fb0120"
            color_degraded = "#fda331"
    }

    order += "wireless wlp1s0"
    order += "ethernet tailscale0"
    order += "cpu_usage"
    order += "memory"
    order += "battery 0"
    order += "cpu_temperature 0"
    order += "disk /"
    order += "tztime local"

    wireless wlp1s0 {
            format_up = " %essid %quality"
            format_down = " down"
    }

    ethernet tailscale0 {
            format_up = " %ip"
            format_down = ""
    }

    cpu_usage {
            format = " %usage"
    }

    memory {
            format = " %used"
            threshold_degraded = "10%"
            format_degraded = " %free"
    }

    battery 0 {
            format = "%status %percentage"
            status_chr = "⚡"
            status_bat = "BAT"
            status_full = "FULL"
            integer_battery_capacity = true
            low_threshold = 15
    }

    cpu_temperature 0 {
            format = " %degrees°C"
    }

    disk "/" {
            format = " %free"
    }

    tztime local {
            format = "%A, %d %B %Y %H:%M:%S"
    }
  '';

  # Wallpapers used by i3 (background) and i3lock (lock screen).
  xdg.configFile."pictures/dark-waves.jpg" = { source = ../../dotfiles/pictures/dark-waves.jpg; force = true; };
  xdg.configFile."pictures/sky.png"        = { source = ../../dotfiles/pictures/sky.png;        force = true; };

  # picom compositor config (transparency/shadows).
  xdg.configFile."picom.conf".text = ''
    backend = "glx";
    vsync = true;
    corner-radius = 6;
    shadow = true;
    shadow-radius = 12;
    shadow-opacity = 0.5;
    fading = true;
    fade-in-step = 0.06;
    fade-out-step = 0.06;
    inactive-opacity = 1.0;
    active-opacity = 1.0;
  '';

  # rofi launcher — base16 dark theme to match kitty/i3.
  programs.rofi = {
    enable = true;
    terminal = "${pkgs.kitty}/bin/kitty";
    theme = "Arc-Dark";
  };

  # dunst notification daemon (replaces xfce4-notifyd/notification-daemon).
  services.dunst.enable = true;

  # X11 desktop runtime tools.
  home.packages = with pkgs; [
    feh                    # Wallpaper setter
    picom                  # Compositor
    flameshot              # Screenshot tool (Mod+p)
    i3lock                 # Screen locker
    brightnessctl          # Backlight control
    playerctl              # MPRIS media control
    pavucontrol            # PipeWire/PulseAudio volume GUI
    networkmanagerapplet   # nm-applet
    libnotify              # notify-send
    xclip                  # X11 clipboard
    xsel                   # X11 selection
    arandr                 # GUI display arrangement (xrandr front-end)
    lxappearance           # GTK theme switcher (matches Debian setup)
  ];
}
