{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.my) mkEnableOpt mkPkgOpt;
in {
  options.modules.programs.brave = {
    enable = mkEnableOpt "Enable Brave browser configuration.";
    package = mkPkgOpt pkgs.brave "brave";
  };

  config.user.home.programs.brave = config.modules.programs.brave;

  config.xdg.mime.defaultApplications = mkIf config.modules.programs.brave.enable {
    "text/html" = "brave-browser.desktop";
    "x-scheme-handler/http" = "brave-browser.desktop";
    "x-scheme-handler/https" = "brave-browser.desktop";
  };
}
