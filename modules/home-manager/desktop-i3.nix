{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.local.i3;

  mod = "Mod4";
  # vim-style focus keys, matching the Debian i3 config
  up = "l";
  down = "k";
  left = "j";
  right = "semicolon";
  term = "kitty";
  rofiRun = "rofi -combi-modi window#drun -show combi -modi combi -show-icons";
  rofiWin = "rofi -show window";
  refresh = "killall -SIGUSR1 i3status";

  systemMode = "(l)ock, (e)xit, (r)eboot, (Shift+s)hutdown";

  # -----------------------------------------------------------------------
  # cendre palette (soft) — single source of truth for i3 borders, polybar,
  # and rofi. Lifted from the kitty/neovim theme so the whole X11 session
  # reads as one system. github.com/Aejkatappaja/cendre
  # -----------------------------------------------------------------------
  cendre = {
    base = "#231f1d"; # background
    mantle = "#1a1716"; # darker surface (inactive tab bg)
    surface = "#2d2725"; # color0 / raised
    text = "#e6d5c2"; # foreground
    subtext = "#a09384"; # color7 / dim text
    muted = "#73665b"; # color8 / disabled
    overlay = "#443c39"; # inactive border
    accent = "#ea9875"; # cursor / active accent (salmon)
    red = "#d1766e";
    green = "#99af6b";
    yellow = "#fcba81";
    blue = "#58bdff";
    magenta = "#9480ba";
    cyan = "#4e89a2";
    urgent = "#d25780"; # bright red
  };
in {
  # -----------------------------------------------------------------------
  # Per-host knobs — the i3 config below is shared between horus and thoth;
  # these options carry the machine-specific interface / output names.
  # -----------------------------------------------------------------------
  options.local.i3 = {
    wirelessInterface = lib.mkOption {
      type = lib.types.str;
      default = "wlp1s0";
      example = "wlan0";
      description = "Wireless interface name shown in the i3status bar.";
    };

    primaryOutput = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "HDMI-1";
      description = ''
        External display (xrandr output name) forced on as primary at
        startup, turning the internal panel off. Null disables the
        external-monitor autoconfig entirely (internal panel stays on).
      '';
    };

    internalOutput = lib.mkOption {
      type = lib.types.str;
      default = "eDP-1";
      description = "Internal laptop panel output (xrandr name).";
    };
  };

  config = {
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
          names = ["JetBrains Mono"];
          size = 10.0;
        };

        gaps = {
          inner = 8;
          outer = 4;
          smartGaps = true;
        };

        # Thin borderless-title edge; cendre accent on the focused window is
        # the focus indicator (picom rounds these corners to match).
        window.border = 2;
        window.titlebar = false;

        keybindings = {
          "${mod}+Return" = "exec ${term}";
          "${mod}+q" = "kill";

          "${mod}+d" = "exec --no-startup-id ${rofiRun}";
          "${mod}+g" = "exec --no-startup-id ${rofiWin}";

          # focus (vim keys + arrows)
          "${mod}+${left}" = "focus left";
          "${mod}+${down}" = "focus down";
          "${mod}+${up}" = "focus up";
          "${mod}+${right}" = "focus right";
          "${mod}+Left" = "focus left";
          "${mod}+Down" = "focus down";
          "${mod}+Up" = "focus up";
          "${mod}+Right" = "focus right";

          # move
          "${mod}+Shift+${left}" = "move left";
          "${mod}+Shift+${down}" = "move down";
          "${mod}+Shift+${up}" = "move up";
          "${mod}+Shift+${right}" = "move right";
          "${mod}+Shift+Left" = "move left";
          "${mod}+Shift+Down" = "move down";
          "${mod}+Shift+Up" = "move up";
          "${mod}+Shift+Right" = "move right";

          # layout
          "${mod}+minus" = "split h";
          "${mod}+backslash" = "split v";
          "${mod}+f" = "fullscreen toggle";
          "${mod}+s" = "layout stacking";
          "${mod}+w" = "layout tabbed";
          "${mod}+e" = "layout toggle split";
          "${mod}+Shift+space" = "floating toggle";
          "${mod}+space" = "focus mode_toggle";
          "${mod}+a" = "focus parent";

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
          "XF86AudioMute" = "exec --no-startup-id pactl set-sink-mute @DEFAULT_SINK@ toggle && ${refresh}";
          "XF86AudioMicMute" = "exec --no-startup-id pactl set-source-mute @DEFAULT_SOURCE@ toggle && ${refresh}";
          "XF86MonBrightnessUp" = "exec --no-startup-id brightnessctl set +10%";
          "XF86MonBrightnessDown" = "exec --no-startup-id brightnessctl set 10%-";
        };

        modes = {
          resize = {
            "${left}" = "resize shrink width 10 px or 10 ppt";
            "${down}" = "resize grow height 10 px or 10 ppt";
            "${up}" = "resize shrink height 10 px or 10 ppt";
            "${right}" = "resize grow width 10 px or 10 ppt";
            "Left" = "resize shrink width 10 px or 10 ppt";
            "Down" = "resize grow height 10 px or 10 ppt";
            "Up" = "resize shrink height 10 px or 10 ppt";
            "Right" = "resize grow width 10 px or 10 ppt";
            "Return" = ''mode "default"'';
            "Escape" = ''mode "default"'';
            "${mod}+r" = ''mode "default"'';
          };
          "${systemMode}" = {
            "l" = ''exec --no-startup-id i3lock -i "$HOME/.config/pictures/sky.png", mode "default"'';
            "e" = ''exec --no-startup-id i3-msg exit, mode "default"'';
            "r" = ''exec --no-startup-id systemctl reboot, mode "default"'';
            "Shift+s" = ''exec --no-startup-id systemctl poweroff, mode "default"'';
            "Return" = ''mode "default"'';
            "Escape" = ''mode "default"'';
          };
        };

        # Send kitty to ws1 and Brave to ws2 (X11 window classes).
        assigns = {
          "1" = [{class = "kitty";}];
          "2" = [{class = "brave-browser";}];
        };

        startup = [
          {
            command = "feh --no-fehbg --bg-fill $HOME/.config/pictures/golden-mountains.png";
            always = true;
            notification = false;
          }
          {
            command = "picom --config ~/.config/picom.conf -b";
            always = true;
            notification = false;
          }
          {
            command = "$HOME/.config/eww/launch.sh";
            always = true;
            notification = false;
          }
          {
            command = "i3-msg 'workspace 1; exec kitty'";
            notification = false;
          }
          {
            command = "i3-msg 'workspace 2; exec brave'";
            notification = false;
          }
        ];

        # Custom bar defined in extraConfig below.
        bars = [];
      };

      # i3bar + i3status, client colours, and display tweaks — verbatim from the
      # Debian config (client.* uses the original 4-field form).
      extraConfig =
        ''
          # Drop the title bar on floating windows too (tiled ones are already
          # borderless via window.titlebar = false); keep the 2px cendre edge.
          default_floating_border pixel 2

          # Window borders — cendre. Fields: border background text indicator child_border
          client.focused          ${cendre.accent}  ${cendre.accent}  ${cendre.base}    ${cendre.accent}  ${cendre.accent}
          client.focused_inactive ${cendre.overlay} ${cendre.mantle}  ${cendre.subtext} ${cendre.overlay} ${cendre.overlay}
          client.unfocused        ${cendre.surface} ${cendre.mantle}  ${cendre.muted}   ${cendre.surface} ${cendre.surface}
          client.urgent           ${cendre.urgent}  ${cendre.urgent}  ${cendre.base}    ${cendre.urgent}  ${cendre.urgent}

          # Disable screen blanking / DPMS (mirrors the old `xset s off -dpms`).
          exec_always --no-startup-id xset s off
          exec_always --no-startup-id xset -dpms
          exec_always --no-startup-id xset s noblank
        ''
        + lib.optionalString (cfg.primaryOutput != null) ''

          # External monitor as primary; laptop panel off when connected.
          exec_always --no-startup-id xrandr --output ${cfg.primaryOutput} --auto --primary --output ${cfg.internalOutput} --off
          workspace 1 output ${cfg.primaryOutput}
        '';
    };

    # eww bar — cendre pills via GTK CSS border-radius. Config in dotfiles/eww.
    xdg.configFile."eww/eww.yuck".source = ../../dotfiles/eww/eww.yuck;
    xdg.configFile."eww/eww.scss".source = ../../dotfiles/eww/eww.scss;
    xdg.configFile."eww/launch.sh" = {
      source = ../../dotfiles/eww/launch.sh;
      executable = true;
    };
    xdg.configFile."eww/scripts/workspaces.sh" = {
      source = ../../dotfiles/eww/scripts/workspaces.sh;
      executable = true;
    };
    xdg.configFile."eww/scripts/wifi.sh" = {
      source = ../../dotfiles/eww/scripts/wifi.sh;
      executable = true;
    };
    xdg.configFile."eww/scripts/tailscale.sh" = {
      source = ../../dotfiles/eww/scripts/tailscale.sh;
      executable = true;
    };

    # Wallpapers used by i3 (background) and i3lock (lock screen).
    xdg.configFile."pictures/golden-mountains.png" = {
      source = ../../dotfiles/pictures/golden-mountains.png;
      force = true;
    };
    xdg.configFile."pictures/sky.png" = {
      source = ../../dotfiles/pictures/sky.png;
      force = true;
    };

    # picom compositor config (transparency/shadows).
    xdg.configFile."picom.conf".text = ''
      backend = "glx";
      vsync = true;
      corner-radius = 10;
      shadow = true;
      shadow-radius = 12;
      shadow-opacity = 0.5;
      fading = true;
      fade-in-step = 0.06;
      fade-out-step = 0.06;
      inactive-opacity = 1.0;
      active-opacity = 1.0;
    '';

    # rofi launcher — cendre theme, rounded to match picom/polybar (10px).
    programs.rofi = {
      enable = true;
      terminal = "${pkgs.kitty}/bin/kitty";
      font = "Iosevka Nerd Font Mono 12";
      theme = let
        inherit (config.lib.formats.rasi) mkLiteral;
      in {
        "*" = {
          bg = mkLiteral cendre.base;
          bg-alt = mkLiteral cendre.mantle;
          fg = mkLiteral cendre.text;
          fg-dim = mkLiteral cendre.subtext;
          accent = mkLiteral cendre.accent;
          urgent = mkLiteral cendre.urgent;
          background-color = mkLiteral "transparent";
          text-color = mkLiteral "@fg";
        };

        "window" = {
          background-color = mkLiteral "@bg";
          border = mkLiteral "2px";
          border-color = mkLiteral "@accent";
          border-radius = mkLiteral "10px";
          width = mkLiteral "38%";
          padding = mkLiteral "12px";
        };

        "mainbox" = {
          spacing = mkLiteral "10px";
          children = map mkLiteral ["inputbar" "listview"];
        };

        "inputbar" = {
          background-color = mkLiteral "@bg-alt";
          border-radius = mkLiteral "8px";
          padding = mkLiteral "8px 12px";
          spacing = mkLiteral "8px";
          children = map mkLiteral ["prompt" "entry"];
        };

        "prompt".text-color = mkLiteral "@accent";
        "entry".placeholder = "search";
        "entry".placeholder-color = mkLiteral "@fg-dim";

        "listview" = {
          lines = mkLiteral "8";
          columns = mkLiteral "1";
          spacing = mkLiteral "4px";
          scrollbar = mkLiteral "false";
          fixed-height = mkLiteral "false";
        };

        "element" = {
          padding = mkLiteral "8px 12px";
          border-radius = mkLiteral "8px";
          spacing = mkLiteral "10px";
        };
        "element normal.normal".text-color = mkLiteral "@fg";
        "element alternate.normal".text-color = mkLiteral "@fg";
        "element selected.normal" = {
          background-color = mkLiteral "@accent";
          text-color = mkLiteral "@bg";
        };
        "element urgent.normal".text-color = mkLiteral "@urgent";
        "element-icon".size = mkLiteral "1.1em";
        "element-text".vertical-align = mkLiteral "0.5";
      };
    };

    # dunst notification daemon (replaces xfce4-notifyd/notification-daemon).
    services.dunst.enable = true;

    # X11 desktop runtime tools.
    home.packages = with pkgs; [
      eww # Status bar (cendre pills)
      feh # Wallpaper setter
      picom # Compositor
      flameshot # Screenshot tool (Mod+p)
      i3lock # Screen locker
      brightnessctl # Backlight control
      playerctl # MPRIS media control
      pavucontrol # PipeWire/PulseAudio volume GUI
      networkmanagerapplet # nm-applet
      libnotify # notify-send
      xclip # X11 clipboard
      xsel # X11 selection
      arandr # GUI display arrangement (xrandr front-end)
      lxappearance # GTK theme switcher (matches Debian setup)
    ];
  };
}
