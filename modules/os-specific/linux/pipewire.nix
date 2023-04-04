{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  inherit (pkgs.stdenv) isLinux;
in {
  options.modules.services.pipewire.enable = mkEnableOption "pipewire";

  config.services.pipewire = mkIf isLinux {
    inherit (config.modules.services.pipewire) enable;

    pulse.enable = true;
    jack.enable = false;
    alsa.enable = true;
  };
}
