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

  config = mkIf isLinux {
    services.pipewire = {
      inherit (config.modules.services.pipewire) enable;

      pulse.enable = true;
      jack.enable = false;
      alsa.enable = true;
    };
  };
}
