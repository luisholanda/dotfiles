{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.my) mkBoolOpt;
in {
  options.host.hardware.isIntel = mkBoolOpt false "Is the host CPU an Intel CPU?";

  config = mkIf config.host.hardware.isIntel {
    hardware.cpu.intel.updateMicrocode = true;
    #hardware.opengl.extraPackages = with pkgs; [
    #  intel-media-driver
    #  intel-compute-runtime
    #  vaapiIntel
    #  vaapiVdpau
    #  libvdpau-va-gl
    #];
  };
}
