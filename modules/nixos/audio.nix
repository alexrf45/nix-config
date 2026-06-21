{ pkgs, ... }:
{
  # Disable PulseAudio — PipeWire replaces it entirely
  services.pulseaudio.enable = false;

  # Real-time scheduling for audio (required by PipeWire)
  security.rtkit.enable = true;

  # PipeWire stack
  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;    # 32-bit app compat (wine, steam)
    };
    pulse.enable = true;      # PulseAudio compatibility shim
    jack.enable = false;      # Enable for audio production
    wireplumber.enable = true;
  };

  # Bluetooth audio manager tray applet
  services.blueman.enable = true;
}
