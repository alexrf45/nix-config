{ pkgs, config, ... }:
{
  # -----------------------------------------------------------------------
  # i3 config — managed as xdg.configFile to mirror dotfiles exactly.
  # The i3 config file is stored at dotfiles/i3/config in this repo.
  # -----------------------------------------------------------------------
  xdg.configFile."i3/config"      = { source = ../../dotfiles/i3/config;        force = true; };
  xdg.configFile."i3/i3blocks.conf" = { source = ../../dotfiles/i3/i3blocks.conf; force = true; };
  xdg.configFile."i3/i3status.conf" = { source = ../../dotfiles/i3/i3status.conf; force = true; };

  # -----------------------------------------------------------------------
  # picom compositor — started by i3 config (exec --no-startup-id picom)
  # -----------------------------------------------------------------------
  xdg.configFile."picom.conf" = { source = ../../dotfiles/picom.conf; force = true; };

  # -----------------------------------------------------------------------
  # Wallpaper + lock screen images
  # i3 config refs: feh --bg-fill ~/.config/pictures/skull.jpg
  #                 i3lock -i ~/.config/pictures/sky.png
  # -----------------------------------------------------------------------
  xdg.configFile."pictures/skull.jpg" = { source = ../../dotfiles/pictures/skull.jpg; force = true; };
  xdg.configFile."pictures/sky.png"   = { source = ../../dotfiles/pictures/sky.png;   force = true; };

  # -----------------------------------------------------------------------
  # Desktop packages (picom, rofi, network tray, etc.)
  # -----------------------------------------------------------------------
  home.packages = with pkgs; [
    picom
    rofi
    networkmanagerapplet   # nm-applet for system tray
    xclip                  # Clipboard CLI
    xdotool                # X automation
    xorg.xrandr
    feh                    # Wallpaper setter
    maim                   # Screenshot tool
    pavucontrol            # PipeWire/PulseAudio GUI volume control
    brightnessctl          # Keyboard brightness control
    playerctl              # Media key control (MPRIS)
    dunst                  # Notification daemon
    libnotify              # notify-send
  ];
}
