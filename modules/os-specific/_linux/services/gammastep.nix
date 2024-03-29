{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
in {
  options.modules.services.gammastep.enable = mkEnableOption "gammastep";

  config.user.home.services.gammastep = {
    inherit (config.location) provider;
    inherit (config.modules.services.gammastep) enable;
    settings.general.adjustment-method = mkIf config.modules.services.sway.enable "wayland";
  };
}
