{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf;
  inherit (lib.my) mkBoolOpt;
  inherit (pkgs.stdenv) isLinux;
in {
  options.host.hardware.isIntel = mkBoolOpt false "Is the host CPU an Intel CPU?";

  config = mkIf (config.host.hardware.isIntel && isLinux) {
    hardware.cpu.intel.updateMicrocode = true;
    hardware.opengl.extraPackages = with pkgs; [ intel-media-driver vaapiIntel vaapiVdpau libvdpau-va-gl ];
  };
}
