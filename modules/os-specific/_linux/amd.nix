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
      hardware.graphics.enable32Bit = true;
      chaotic.mesa-git.enable = false;
      chaotic.mesa-git.fallbackSpecialisation = true;
      chaotic.mesa-git.replaceBasePackage = true;
    })
    (mkIf isAMD {
      hardware.cpu.amd.updateMicrocode = true;
    })
    (mkIf gpu.isAMD {
      environment.variables.AMD_VULKAN_ICD = "RADV";

      hardware.amdgpu = {
        amdvlk = {
          enable = false;
          package = pkgs.unstable.amdvlk;
          supportExperimental.enable = true;
          settings = {
            ShaderCacheMode = 2;
            RequestHighPriorityVmid = 1;
            EnableNativeFence = 1;
            LdsPsGroupSize = 1;
          };
        };
        initrd.enable = true;
      };
      programs.corectrl.enable = true;
      programs.corectrl.gpuOverclock.enable = true;

      services.ollama.acceleration = "rocm";
      user.groups = ["corectrl"];
    })
  ];
}
