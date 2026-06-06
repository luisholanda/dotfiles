{
  config,
  lib,
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
    })
    (mkIf isAMD {
      hardware.cpu.amd.updateMicrocode = true;
    })
    (mkIf gpu.isAMD {
      environment.variables.AMD_VULKAN_ICD = "RADV";

      hardware.amdgpu.initrd.enable = true;
      hardware.amdgpu.overdrive.enable = true;

      user.groups = ["corectrl"];
    })
  ];
}
