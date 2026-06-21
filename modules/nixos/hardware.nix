{ config, pkgs, lib, ... }:
{
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
      "amd_pstate=active"        # AMD P-state driver (Ryzen power management)
      "mem_sleep_default=deep"   # S3 deep sleep for better suspend
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
      rocmPackages.clr           # ROCm OpenCL runtime
    ];
  };

  # NVIDIA driver (proprietary)
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    modesetting.enable = true;         # Required for PRIME offload
    powerManagement.enable = true;     # Reliable suspend/resume
    powerManagement.finegrained = false;
    open = false;                      # Proprietary driver
    nvidiaSettings = true;

    # PRIME offload: NVIDIA dGPU only runs when invoked via `nvidia-offload <cmd>`
    # AMD iGPU handles the display pipeline — battery is preserved.
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;   # Installs `nvidia-offload` wrapper
      };
      # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      # PLACEHOLDERS — replace with actual values from:
      #   lspci | grep -E 'VGA|3D'
      # Format: "XX:YY.Z" → "PCI:XX:YY:Z"
      # Example output:
      #   06:00.0 VGA: AMD Radeon   → amdgpuBusId = "PCI:6:0:0"
      #   01:00.0 3D: NVIDIA        → nvidiaBusId  = "PCI:1:0:0"
      # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      amdgpuBusId = "PCI:4:0:0";   # PLACEHOLDER
      nvidiaBusId  = "PCI:1:0:0";  # PLACEHOLDER
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
  hardware.enableRedistributableFirmware = true;   # WiFi, BT, etc.

  # -----------------------------------------------------------------------
  # Bluetooth
  # -----------------------------------------------------------------------
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings.General.Experimental = "true";   # Battery level reporting
  };
}
