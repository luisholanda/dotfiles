{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  inherit (lib.my) mkAttrsOpt mkCssFileOpt;

  cfg = config.modules.services.sway.notification-center;
in {
  options.modules.services.sway.notification-center = {
    enable = mkEnableOption "SwayNotificationCenter";
    config = mkAttrsOpt "The configuration of swaync";
    styleFile = mkCssFileOpt "The CSS file used to style swaync.";
  };

  config = mkIf cfg.enable {
    user.packages = [pkgs.swaynotificationcenter];

    user.xdg.configFile."swaync/config.json".text = builtins.toJSON cfg.config;
    user.xdg.configFile."swaync/style.css".source = cfg.styleFile;
  };
}
