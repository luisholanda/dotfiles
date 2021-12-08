{ config, lib, pkgs, ... }:
let
  inherit (builtins) typesOf concatStringSep;
  inherit (lib) mkOption types mkIf mapAttrsToList;
  inherit (lib.my) mkBoolOpt mkCssOpt mkEnableOpt cssOptToStr;

  cfg = config.modules.services.waybar;
in {
  options.modules.services.waybar = {
    enable = mkEnableOpt "Enable waybar configuration.";
    settings = mkOption {
      type = types.listOf (types.attrs);
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
      enable = true;
      settings = cfg.settings;
      style = cssOptToStr cfg.style;
      systemd.enable = cfg.systemd.enable;
    };

    user.home.extraConfig.wayland.windowManager.sway.config.barrs = [{ command = "waybar"; }];
  };
}
