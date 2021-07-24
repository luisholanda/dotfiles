{ config, lib, pkgs, ... }:
let
  inherit (lib.my) mkAttrsOpt mkEnableOpt mkPkgOpt mkPkgsOpt;

  cfg = config.modules.programs.mpv;
in {
  options.modules.programs.mpv = {
    enable = mkEnableOpt "Enable MPV media player.";
    package = mkPkgOpt pkgs.mpv "Package providing mpv";

    config = mkAttrsOpt "MPV configuration options.";
    scripts = mkPkgsOpt "MPV scripts";
  };

  config = {
    user.home.programs.mpv = {
      enable = cfg.enable;
      package = cfg.package;

      config = cfg.config;
      scripts = cfg.scripts;
    };
  };
}
