{ config, pkgs, lib, ... }: let
  inherit (lib) mkEnableOption mkIf;
  inherit (lib.my) mkPathOpt;

  cfg = config.modules.services.wluma;
in {
  options.modules.services.wluma = {
    enable = mkEnableOption "WLuma - automatic brightness control";
    configFile = mkPathOpt "wluma configuration file";
  };

  config = mkIf cfg.enable {
    modules.services.sway.config.startup = [
      { command = "${pkgs.wluma}/bin/wluma"; always = true; }
    ];

    user.xdg.configFile."wluma/config.toml".source = cfg.configFile;
  };
}
