{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  inherit (pkgs.stdenv) isLinux;
in {
  options.modules.services.gammastep.enable = mkEnableOption "gammastep";

  config = mkIf isLinux {
    user.home.services.gammastep = {
      inherit (config.location) provider;
      inherit (config.modules.services.gammastep) enable;
      settings.general.adjustment-method = mkIf config.modules.services.sway.enable "wayland";
    };
  };
}
