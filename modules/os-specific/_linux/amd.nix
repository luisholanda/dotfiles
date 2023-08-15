{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.my) mkBoolOpt;
  inherit (config.host.hardware) isAMD;
in {
  options.host.hardware.isAMD = mkBoolOpt false "Is the host CPU an AMD CPU?";

  config = mkIf isAMD {
    boot.initrd.kernelModules = ["amdgpu"];
    hardware.cpu.amd.updateMicrocode = true;
    hardware.opengl.extraPackages = with pkgs; [rocm-opencl-icd rocm-opencl-runtime];
    hardware.opengl.driSupport = true;
    hardware.opengl.driSupport32Bit = true;
    environment.variables.AMD_VULKAN_ICD = "RADV";
  };
}
