{...}: {
  # -----------------------------------------------------------------------
  # Steam
  # -----------------------------------------------------------------------
  # 32-bit graphics/audio support is already enabled system-wide
  # (hardware.graphics.enable32Bit, pipewire.alsa.support32Bit) — Steam
  # just needs to be turned on.
  programs.steam.enable = true;

  # Steam Controller / Steam Deck controller udev rules.
  hardware.steam-hardware.enable = true;

  # -----------------------------------------------------------------------
  # GameMode — temporary CPU performance profile while a game runs.
  # Defaults (renice via the built-in setuid wrapper) are sufficient; GPU
  # clock overrides are left unset — ambiguous target on this host's
  # AMD-display/NVIDIA-PRIME-offload hybrid setup and upstream flags them
  # as hardware-risk.
  # -----------------------------------------------------------------------
  programs.gamemode.enable = true;
}
