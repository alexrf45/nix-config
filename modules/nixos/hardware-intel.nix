{
  config,
  pkgs,
  lib,
  ...
}: {
  # -----------------------------------------------------------------------
  # Boot
  # -----------------------------------------------------------------------
  boot = {
    loader = {
      systemd-boot.enable = true;
      systemd-boot.configurationLimit = 10;
      efi.canTouchEfiVariables = true;
    };

    # Stock kernel — Intel Tiger Lake is well supported out of the box.
    # Swap to pkgs.linuxPackages_zen for lower desktop latency if desired.
    kernelPackages = pkgs.linuxPackages;

    kernelParams = [
      "mem_sleep_default=deep" # S3 deep sleep for better suspend
    ];
  };

  # -----------------------------------------------------------------------
  # Intel CPU microcode
  # -----------------------------------------------------------------------
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # -----------------------------------------------------------------------
  # Graphics: Intel Iris Xe (Tiger Lake) — single iGPU, no discrete GPU.
  # intel-media-driver is the modern iHD VA-API driver (Gen11+).
  # -----------------------------------------------------------------------
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver # iHD VA-API driver (Tiger Lake/Iris Xe)
      vpl-gpu-rt # oneVPL runtime for hardware video encode/decode
    ];
  };

  services.xserver.videoDrivers = ["modesetting"];

  # Intel Iris Xe → iHD VA-API driver for hardware video decode.
  environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";

  # -----------------------------------------------------------------------
  # Firmware
  # -----------------------------------------------------------------------
  # firmware-realtek (RTL8821CE WiFi/BT) + SOF audio firmware are pulled in by
  # enableRedistributableFirmware; the rtw88_8821ce driver is in-tree (6.12).
  hardware.enableRedistributableFirmware = true;

  # -----------------------------------------------------------------------
  # Bluetooth
  # -----------------------------------------------------------------------
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = "true"; # Battery level reporting
        FastConnectable = "true"; # Faster reconnect on resume/boot
        JustWorksRepairing = "always"; # Skip re-pair prompt for known devices
      };
      Policy.AutoEnable = "true"; # Keep adapter enabled after suspend
      LE.MinConnectionInterval = 7; # Tighten BLE interval (headphones)
    };
  };

  # -----------------------------------------------------------------------
  # Laptop power management — mirrors the Debian tlp/thermald setup.
  # -----------------------------------------------------------------------
  services.thermald.enable = true; # Intel thermal management daemon
  services.tlp.enable = true; # Battery/power tuning (conflicts with power-profiles-daemon)

  # Lid close does nothing — keep running when docked to external monitor.
  services.logind.lidSwitch = "ignore";

  # -----------------------------------------------------------------------
  # TPM 2.0 present (/dev/tpm0) — expose tools for measured-boot experiments.
  # -----------------------------------------------------------------------
  security.tpm2.enable = true;
}
