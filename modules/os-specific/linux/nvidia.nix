{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.my) mkBoolOpt;
  inherit (lib) mkIf;
in {
  options.host.hardware.gpu.isNVIDIA = mkBoolOpt false "Is this host using a NVIDIA GPU?";

  config = mkIf config.host.hardware.gpu.isNVIDIA {
    services.xserver.videoDrivers = ["nvidia"];
    hardware.opengl.extraPackages = with pkgs; [vaapiVdpau nvidia-vaapi-driver];
    hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.vulkan_beta;

    boot.kernelParams = [
      "nvidia_drm.modeset=1"
      # FIXME: This should be added based on blacklistedKernelModules
      "module_blacklist=i915"
    ];
    boot.initrd.kernelModules = ["nvidia" "nvidia_modeset" "nvidia-uvm" "nvidia_drm"];

    boot.blacklistedKernelModules = ["i915"];

    # Force Vulkan to use the nvidia card, otherwise, it will use LLVMpipe by default.
    #environment.variables.VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json";

    environment.sessionVariables = {
      LIBVA_DRIVER_NAME = "nvidia";
      GBM_BACKEND = "nvidia-drm";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      WLR_NO_HARDWARE_CURSORS = "1";
    };
  };
}
