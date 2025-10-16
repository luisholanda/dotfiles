{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkMerge;
  inherit (lib.my) mkEnableOpt mkPkgOpt isLinux;
in {
  options.modules.programs.brave = {
    enable = mkEnableOpt "Enable Brave browser configuration.";
    package = mkPkgOpt pkgs.brave "brave";
  };

  config = mkMerge [
    {
      user.home.programs.brave = config.modules.programs.brave;
    }
    (
      if isLinux
      then
        mkIf config.modules.programs.brave.enable {
          xdg.mime.defaultApplications = {
            "text/html" = "brave-browser.desktop";
            "x-scheme-handler/http" = "brave-browser.desktop";
            "x-scheme-handler/https" = "brave-browser.desktop";
          };
        }
      else {}
    )
  ];
}
