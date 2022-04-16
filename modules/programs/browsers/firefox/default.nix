{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (builtins) readFile concatStringsSep;
  inherit (lib) mkIf mkOption types;
  inherit (lib.my) flattenAttrs mkCssFileOpt mkCssFilesOpt mkEnableOpt mkPkgsOpt;

  cfg = config.modules.programs.firefox;
  hasWayland = config.modules.services.sway.enable;
in {
  options.modules.programs.firefox = {
    enable = mkEnableOpt "Enable Firefox configuration.";
    extensions = mkPkgsOpt "Firefox extensions";

    settings = mkOption {
      type = types.attrs;
      default = {};
      description = "Firefox about:config settings.";
    };

    userChrome = mkCssFileOpt "Path to the userChrome.css file.";
    userContent = mkCssFilesOpt "List of stylesheets to include in the userContent.css file.";
  };

  config = mkIf cfg.enable {
    user.home.programs.firefox = {
      inherit (cfg) extensions;
      enable = true;
      package =
        if hasWayland
        then pkgs.firefox-wayland
        else pkgs.firefox;

      profiles = {
        default = {
          id = 0;
          settings = flattenAttrs cfg.settings;
          userChrome = readFile cfg.userChrome;
          userContent = concatStringsSep "\n\n" (map readFile cfg.userContent);
        };
      };
    };
  };
}
