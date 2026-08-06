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

  # Nerd Font glyphs via JSON \u escapes — deterministic bytes. Literal PUA
  # glyphs get mangled when the source is edited, so never inline them.
  ico = {
    lcap = builtins.fromJSON ''""''; # rounded left pill cap
    rcap = builtins.fromJSON ''""''; # rounded right pill cap
    cpu = builtins.fromJSON ''""''; # microchip
    mem = builtins.fromJSON ''""''; # database
    temp = builtins.fromJSON ''""''; # thermometer
    disk = builtins.fromJSON ''""''; # hdd
    wifi = builtins.fromJSON ''""''; # wifi
    battChg = builtins.fromJSON ''""''; # bolt (charging)
    batt = builtins.fromJSON ''""''; # battery full
    battLow = builtins.fromJSON ''""''; # battery empty
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

    batteryName = lib.mkOption {
      type = lib.types.str;
      default = "BAT0";
      example = "BAT1";
      description = "Battery device name under /sys/class/power_supply for the polybar battery module.";
    };

    acAdapter = lib.mkOption {
      type = lib.types.str;
      default = "AC";
      example = "ADP1";
      description = "AC adapter device name under /sys/class/power_supply for the polybar battery module.";
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
            command = "$HOME/.config/polybar/launch.sh";
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

    # Polybar launcher — killed and relaunched on i3 start/reload.
    xdg.configFile."polybar/launch.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        pkill -x polybar
        while pgrep -x polybar >/dev/null; do sleep 0.2; done
        polybar main &
      '';
    };

    # Polybar bar — GNOME-style: a solid cendre bar with each module in a
    # rounded "pill" (powerline round caps in surface over the base bar),
    # monochrome accent icons, centered clock. Modules mirror the old
    # i3status set. Round caps use font-2 via %{T3}; pill body is the label
    # background, so caps sit on the base bar and read as rounded ends.
    xdg.configFile."polybar/config.ini".text = ''
      [bar/main]
      width = 99%
      offset-x = 0.5%
      offset-y = 5pt
      height = 24pt
      radius = 10
      bottom = false
      fixed-center = true
      background = ${cendre.base}
      foreground = ${cendre.text}
      line-size = 2pt
      border-size = 0
      padding = 2
      module-margin = 1
      font-0 = UbuntuMono Nerd Font:size=11;2
      font-1 = UbuntuMono Nerd Font:size=11;2
      font-2 = UbuntuMono Nerd Font:size=22;4
      modules-left = i3
      modules-center = date
      modules-right = cpu memory temperature filesystem wireless wired battery
      tray-position = right
      tray-background = ${cendre.base}
      tray-padding = 2
      tray-maxsize = 18
      cursor-click = pointer
      enable-ipc = true
      wm-restack = i3

      [module/i3]
      type = internal/i3
      pin-workspaces = true
      show-urgent = true
      index-sort = true
      enable-click = true
      enable-scroll = true
      wrapping-scroll = false
      format = <label-state> <label-mode>
      label-mode-padding = 2
      label-mode-foreground = ${cendre.base}
      label-mode-background = ${cendre.yellow}
      label-focused = %index%
      label-focused-background = ${cendre.accent}
      label-focused-foreground = ${cendre.base}
      label-focused-padding = 2
      label-visible = %index%
      label-visible-foreground = ${cendre.text}
      label-visible-padding = 2
      label-unfocused = %index%
      label-unfocused-foreground = ${cendre.muted}
      label-unfocused-padding = 2
      label-urgent = %index%
      label-urgent-background = ${cendre.urgent}
      label-urgent-foreground = ${cendre.base}
      label-urgent-padding = 2

      [module/date]
      type = internal/date
      interval = 1
      date = %A, %d %B %Y
      time = %H:%M:%S
      format = <label>
      format-prefix = %{T3}${ico.lcap}%{T-}
      format-prefix-foreground = ${cendre.surface}
      format-suffix = %{T3}${ico.rcap}%{T-}
      format-suffix-foreground = ${cendre.surface}
      label = %{F${cendre.accent}}󰃰%{F-}  %date%   %time%
      label-background = ${cendre.surface}
      label-foreground = ${cendre.text}
      label-padding = 2

      [module/cpu]
      type = internal/cpu
      interval = 2
      format = <label>
      format-prefix = %{T3}${ico.lcap}%{T-}
      format-prefix-foreground = ${cendre.surface}
      format-suffix = %{T3}${ico.rcap}%{T-}
      format-suffix-foreground = ${cendre.surface}
      label = %{F${cendre.blue}}${ico.cpu}%{F-}  %percentage%%
      label-background = ${cendre.surface}
      label-foreground = ${cendre.text}
      label-padding = 2

      [module/memory]
      type = internal/memory
      interval = 2
      format = <label>
      format-prefix = %{T3}${ico.lcap}%{T-}
      format-prefix-foreground = ${cendre.surface}
      format-suffix = %{T3}${ico.rcap}%{T-}
      format-suffix-foreground = ${cendre.surface}
      label = %{F${cendre.green}}${ico.mem}%{F-}  %gb_used%
      label-background = ${cendre.surface}
      label-foreground = ${cendre.text}
      label-padding = 2

      [module/temperature]
      type = internal/temperature
      interval = 2
      thermal-zone = 0
      warn-temperature = 80
      format = <label>
      format-prefix = %{T3}${ico.lcap}%{T-}
      format-prefix-foreground = ${cendre.surface}
      format-suffix = %{T3}${ico.rcap}%{T-}
      format-suffix-foreground = ${cendre.surface}
      format-warn = <label-warn>
      format-warn-prefix = %{T3}${ico.lcap}%{T-}
      format-warn-prefix-foreground = ${cendre.surface}
      format-warn-suffix = %{T3}${ico.rcap}%{T-}
      format-warn-suffix-foreground = ${cendre.surface}
      label = %{F${cendre.yellow}}${ico.temp}%{F-}  %temperature-c%
      label-background = ${cendre.surface}
      label-foreground = ${cendre.text}
      label-padding = 2
      label-warn = %{F${cendre.red}}${ico.temp}%{F-}  %temperature-c%
      label-warn-background = ${cendre.surface}
      label-warn-foreground = ${cendre.red}
      label-warn-padding = 2

      [module/filesystem]
      type = internal/fs
      interval = 30
      mount-0 = /
      format-mounted = <label-mounted>
      format-mounted-prefix = %{T3}${ico.lcap}%{T-}
      format-mounted-prefix-foreground = ${cendre.surface}
      format-mounted-suffix = %{T3}${ico.rcap}%{T-}
      format-mounted-suffix-foreground = ${cendre.surface}
      label-mounted = %{F${cendre.magenta}}${ico.disk}%{F-}  %free%
      label-mounted-background = ${cendre.surface}
      label-mounted-foreground = ${cendre.text}
      label-mounted-padding = 2
      label-unmounted =

      [module/wireless]
      type = internal/network
      interface = ${cfg.wirelessInterface}
      interval = 5
      format-connected = <label-connected>
      format-connected-prefix = %{T3}${ico.lcap}%{T-}
      format-connected-prefix-foreground = ${cendre.surface}
      format-connected-suffix = %{T3}${ico.rcap}%{T-}
      format-connected-suffix-foreground = ${cendre.surface}
      label-connected = %{F${cendre.cyan}}${ico.wifi}%{F-}  %essid% %signal%%
      label-connected-background = ${cendre.surface}
      label-connected-foreground = ${cendre.text}
      label-connected-padding = 2
      format-disconnected = <label-disconnected>
      format-disconnected-prefix = %{T3}${ico.lcap}%{T-}
      format-disconnected-prefix-foreground = ${cendre.surface}
      format-disconnected-suffix = %{T3}${ico.rcap}%{T-}
      format-disconnected-suffix-foreground = ${cendre.surface}
      label-disconnected = %{F${cendre.muted}}󰤭 down%{F-}
      label-disconnected-background = ${cendre.surface}
      label-disconnected-padding = 2

      [module/wired]
      type = internal/network
      interface = tailscale0
      interval = 5
      format-connected = <label-connected>
      format-connected-prefix = %{T3}${ico.lcap}%{T-}
      format-connected-prefix-foreground = ${cendre.surface}
      format-connected-suffix = %{T3}${ico.rcap}%{T-}
      format-connected-suffix-foreground = ${cendre.surface}
      label-connected = %{F${cendre.cyan}}󰛳%{F-}  %local_ip%
      label-connected-background = ${cendre.surface}
      label-connected-foreground = ${cendre.text}
      label-connected-padding = 2
      format-disconnected =
      label-disconnected =

      [module/battery]
      type = internal/battery
      battery = ${cfg.batteryName}
      adapter = ${cfg.acAdapter}
      full-at = 99
      low-at = 15
      format-charging = <label-charging>
      format-charging-prefix = %{T3}${ico.lcap}%{T-}
      format-charging-prefix-foreground = ${cendre.surface}
      format-charging-suffix = %{T3}${ico.rcap}%{T-}
      format-charging-suffix-foreground = ${cendre.surface}
      label-charging = %{F${cendre.green}}${ico.battChg}%{F-}  %percentage%%
      label-charging-background = ${cendre.surface}
      label-charging-foreground = ${cendre.text}
      label-charging-padding = 2
      format-discharging = <label-discharging>
      format-discharging-prefix = %{T3}${ico.lcap}%{T-}
      format-discharging-prefix-foreground = ${cendre.surface}
      format-discharging-suffix = %{T3}${ico.rcap}%{T-}
      format-discharging-suffix-foreground = ${cendre.surface}
      label-discharging = %{F${cendre.yellow}}${ico.batt}%{F-}  %percentage%%
      label-discharging-background = ${cendre.surface}
      label-discharging-foreground = ${cendre.text}
      label-discharging-padding = 2
      format-full = <label-full>
      format-full-prefix = %{T3}${ico.lcap}%{T-}
      format-full-prefix-foreground = ${cendre.surface}
      format-full-suffix = %{T3}${ico.rcap}%{T-}
      format-full-suffix-foreground = ${cendre.surface}
      label-full = %{F${cendre.green}}${ico.batt}%{F-}  %percentage%%
      label-full-background = ${cendre.surface}
      label-full-foreground = ${cendre.text}
      label-full-padding = 2
      format-low = <label-low>
      format-low-prefix = %{T3}${ico.lcap}%{T-}
      format-low-prefix-foreground = ${cendre.surface}
      format-low-suffix = %{T3}${ico.rcap}%{T-}
      format-low-suffix-foreground = ${cendre.surface}
      label-low = %{F${cendre.red}}${ico.battLow}%{F-}  %percentage%%
      label-low-background = ${cendre.surface}
      label-low-foreground = ${cendre.red}
      label-low-padding = 2
    '';

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
      (polybar.override {
        i3Support = true;
        pulseSupport = true;
      }) # Status bar (cendre)
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
