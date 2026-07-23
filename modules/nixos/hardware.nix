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

    # Zen kernel: lower latency, better desktop responsiveness on AMD laptops
    kernelPackages = pkgs.linuxPackages_zen;

    kernelParams = [
      "amd_pstate=active" # AMD P-state driver (Ryzen power management)
      "mem_sleep_default=deep" # S3 deep sleep for better suspend
    ];

    extraModprobeConfig = ''
      options nvidia NVreg_PreserveVideoMemoryAllocations=1
    '';
  };

  # -----------------------------------------------------------------------
  # AMD CPU microcode
  # -----------------------------------------------------------------------
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # -----------------------------------------------------------------------
  # Graphics: AMD iGPU (display) + NVIDIA dGPU (offload)
  # -----------------------------------------------------------------------
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      rocmPackages.clr # ROCm OpenCL runtime
    ];
  };

  # AMD iGPU drives the display pipeline → radeonsi VA-API for hardware decode.
  environment.sessionVariables.LIBVA_DRIVER_NAME = "radeonsi";

  # NVIDIA driver (proprietary)
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    modesetting.enable = true; # Required for PRIME offload
    powerManagement.enable = true; # Reliable suspend/resume
    powerManagement.finegrained = false;
    open = false; # Proprietary driver
    nvidiaSettings = true;

    # PRIME offload: NVIDIA dGPU only runs when invoked via `nvidia-offload <cmd>`
    # AMD iGPU handles the display pipeline — battery is preserved.
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true; # Installs `nvidia-offload` wrapper
      };
      # Confirmed via `lspci | grep -E 'VGA|3D'` on this machine:
      #   05:00.0 VGA: AMD Renoir/Vega  → amdgpuBusId = "PCI:5:0:0"
      #   01:00.0 3D:  NVIDIA TU117M    → nvidiaBusId  = "PCI:1:0:0"
      amdgpuBusId = "PCI:5:0:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # -----------------------------------------------------------------------
  # Power / Lid — ignore lid close (laptop used docked with external display)
  # -----------------------------------------------------------------------
  services.logind = {
    lidSwitch = "ignore";
    lidSwitchExternalPower = "ignore";
    lidSwitchDocked = "ignore";
  };

  # -----------------------------------------------------------------------
  # Firmware
  # -----------------------------------------------------------------------
  hardware.enableRedistributableFirmware = true; # WiFi, BT, etc.

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
}
