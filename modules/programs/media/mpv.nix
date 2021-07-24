{ config, lib, pkgs, ... }:
let
  inherit (lib.my) mkAttrs mkEnableOpt mkPkgOpt;

  cfg = config.modules.programs.mpv;
in {
  options.modules.programs.mpv = {
    enable = mkEnableOpt "Enable MPV media player.";
    package = mkPkgOpt pkgs.mpv "Package providing mpv";

    config = mkAtrrs "MPV configuration options.";
    scripts = mkPkgsOpts "MPV scripts";
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
