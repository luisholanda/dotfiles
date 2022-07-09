{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.my) mkBoolOpt;
  inherit (pkgs.stdenv) isLinux;
in {
  options.host.hardware.isAMD = mkBoolOpt false "Is the host CPU an AMD CPU?";

  config = mkIf (config.host.hardware.isAMD && isLinux) {
    hardware.cpu.amd.updateMicrocode = true;
    hardware.opengl.extraPackages = with pkgs; [rocm-opencl-icd rocm-opencl-runtime];
    hardware.opengl.driSupport = true;
    hardware.opengl.driSupport32Bit = true;
    environment.variables.AMD_VULKAN_ICD = "RADV";
  };
}
