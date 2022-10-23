{
  config,
  lib,
  ...
}: let
  inherit (lib.my) mkBoolOpt;
  inherit (lib) mkIf;
  inherit (config.host.hardware) isLaptop;
in {
  options.host.hardware.gpu.isNVIDIA = mkBoolOpt false "Is this host using a NVIDIA GPU?";

  config = mkIf config.host.hardware.gpu.isNVIDIA {
    services.xserver.videoDrivers = ["nvidia"];
    hardware.opengl.enable = true;
    hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.latest;
    hardware.nvidia.powerManagement.enable = true;
    #hardware.nvidia.powerManagement.finegrained = true;

    boot.kernelParams = [
      "nvidia_drm.modeset=1"
    ];

    boot.blacklistedKernelModules = mkIf isLaptop ["i915"];
  };
}
