{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkMerge;
  inherit (lib.my) mkBoolOpt;
  inherit (config.host.hardware) isAMD gpu;
in {
  options.host.hardware.isAMD = mkBoolOpt false "Is the host CPU an AMD CPU?";
  options.host.hardware.gpu.isAMD = mkBoolOpt false "Is the host GPU an AMD GPU?";

  config = mkMerge [
    (mkIf (isAMD || gpu.isAMD) {
      boot.initrd.kernelModules = ["amdgpu"];
      hardware.graphics.extraPackages = with pkgs; [rocm-opencl-icd rocm-opencl-runtime];
      hardware.graphics.enable32Bit = true;
      environment.variables.AMD_VULKAN_ICD = "RADV";
      chaotic.mesa-git.enable = true;
      chaotic.mesa-git.fallbackSpecialisation = true;
      chaotic.mesa-git.replaceBasePackage = true;
    })
    (mkIf isAMD {
      hardware.cpu.amd.updateMicrocode = true;
    })
    (mkIf gpu.isAMD {
      programs.corectrl.enable = true;
      programs.corectrl.gpuOverclock.enable = true;
      programs.corectrl.gpuOverclock.ppfeaturemask = "0xffffffff";

      services.ollama.acceleration = "rocm";
      user.groups = ["corectrl"];
    })
  ];
}
