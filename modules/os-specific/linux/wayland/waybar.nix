{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption types mkIf;
  inherit (lib.my) mkCssOpt mkEnableOpt cssOptToStr;

  cfg = config.modules.services.waybar;
in {
  options.modules.services.waybar = {
    enable = mkEnableOpt "Enable waybar configuration.";
    settings = mkOption {
      type = types.listOf types.attrs;
      default = [];
      description = "Configuration for Waybar.";
    };
    style = mkCssOpt {
      description = "CSS style of the bar.";
    };
    systemd.enable = mkEnableOpt "Enable waybar systemd integration.";
  };

  config = mkIf cfg.enable {
    user.home.programs.waybar = {
      inherit (cfg) settings;
      enable = true;
      style = cssOptToStr cfg.style;
      systemd.enable = cfg.systemd.enable;
    };

    user.home.extraConfig.wayland.windowManager.sway.config.barrs = [{command = "waybar";}];
  };
}
