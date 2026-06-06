{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkOption types;
  inherit (lib.my) mkEnableOpt;

  cfg = config.modules.programs.firefox;
in {
  options.modules.programs.firefox = {
    enable = mkEnableOpt "Enable Firefox configuration.";

    settings = mkOption {
      type = types.attrs;
      description = "Firefox about:config settings.";
    };
  };

  config = mkIf cfg.enable {
    user.home.programs.firefox = {
      enable = true;
      package = pkgs.firefox-bin;
      configPath = "${config.user.xdg.configDir}/mozilla/firefox";
    };
  };
}
