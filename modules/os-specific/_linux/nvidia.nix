{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.my) mkBoolOpt;
  inherit (lib) mkIf;
  inherit (config.boot.kernelPackages) nvidiaPackages;

  modprobe = "${pkgs.kmod}/bin/kmod";
in {
  options.host.hardware.gpu.isNVIDIA = mkBoolOpt false "Is this host using a NVIDIA GPU?";

  config = mkIf config.host.hardware.gpu.isNVIDIA {
    services.xserver.videoDrivers = ["nvidia"];
    hardware.opengl.extraPackages = with pkgs; [vaapiVdpau nvidia-vaapi-driver];
    hardware.nvidia.package = nvidiaPackages.vulkan_beta;
    hardware.nvidia.nvidiaPersistenced = true;

    boot.extraModprobeConfig = ''
      options nvidia NVreg_UsePageAttributeTable=1 NVreg_InitializeSystemMemoryAllocations=0 NVreg_DynamicPowerManagement=0x02
      options nvidia_drm modeset=1
    '';

    boot.initrd.kernelModules = ["nvidia" "nvidia_modeset" "nvidia-uvm" "nvidia_drm"];

    boot.blacklistedKernelModules = ["i915"];

    boot.kernelParams = [
      "rcutree.rcu_idle_gp_delay=1"
      "acpi_osi=!"
      "acpi_osi='Linux'"
      "pcie_aspm=off"
    ];

    # Force Vulkan to use the nvidia card, otherwise, it will use LLVMpipe by default.
    #environment.variables.VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json";

    environment.sessionVariables = {
      LIBVA_DRIVER_NAME = "nvidia";
      GBM_BACKEND = "nvidia-drm";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      WLR_NO_HARDWARE_CURSORS = "1";
    };

    services.udev.extraRules = ''
      # Load and unload nvidia-modeset module
      ACTION=="add", DEVPATH=="/bus/pci/drivers/nvidia", RUN+="${modprobe} nvidia-modeset"
      ACTION=="remove", DEVPATH=="/bus/pci/drivers/nvidia", RUN+="${modprobe} -r nvidia-modeset"

      # Load and unload nvidia-drm module
      ACTION=="add", DEVPATH=="/bus/pci/drivers/nvidia", RUN+="${modprobe} nvidia-drm"
      ACTION=="remove", DEVPATH=="/bus/pci/drivers/nvidia", RUN+="${modprobe} -r nvidia-drm"

      # Load and unload nvidia-uvm module
      ACTION=="add", DEVPATH=="/bus/pci/drivers/nvidia", RUN+="${modprobe} nvidia-uvm"
      ACTION=="remove", DEVPATH=="/bus/pci/drivers/nvidia", RUN+="${modprobe} -r nvidia-uvm"

      # Enable runtime PM for NVIDIA VGA/3D controller devices on driver bind
      ACTION=="bind", SUBSYSTEM=="pci", DRIVERS=="nvidia", ATTR{vendor}=="0x10de", ATTR{class}=="0x03[0-9]*", TEST=="power/control", ATTR{power/control}="auto"

      # Disable runtime PM for NVIDIA VGA/3D controller devices on driver unbind
      ACTION=="unbind", SUBSYSTEM=="pci", DRIVERS=="nvidia", ATTR{vendor}=="0x10de", ATTR{class}=="0x03[0-9]*", TEST=="power/control", ATTR{power/control}="on"
    '';
  };
}
