{ config, lib, pkgs, ... }:
let
  inherit (lib.my) mkEnableOpt mkPkgOpt;
in {
  options.modules.programs.brave = {
    enable = mkEnableOpt "Enable Brave browser configuration.";
    package = mkPkgOpt pkgs.brave "brave";
  };

  config.user.home.programs.brave = config.modules.programs.brave;
}
