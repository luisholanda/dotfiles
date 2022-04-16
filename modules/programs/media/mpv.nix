{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkMerge;
  inherit (lib.my) mkAttrsOpt mkEnableOpt mkPkgOpt mkPkgsOpt;

  cfg = config.modules.programs.mpv;

  waylandMpv = pkgs.mpv-unwrapped.override {
    waylandSupport = true;
    x11Support = false;
    xineramaSupport = false;
    xvSupport = false;
    vapoursynthSupport = true;
    vapoursynth = pkgs.vapoursynth.withPlugins [pkgs.vapoursynth-mvtools];
  };

  waylandEnable = config.modules.services.sway.enable;

  defaultMpv =
    if waylandEnable
    then waylandMpv
    else pkgs.mpv;

  mpvDefaultConfig = {
    hwdec = "auto-safe";
    hwdec-codecs = "all";
    vo = "gpu";
    profile = "gpu-hq";
    gpu-context = mkIf waylandEnable "wayland";
    scale = "bicubic_fast";
  };
in {
  options.modules.programs.mpv = {
    enable = mkEnableOpt "Enable MPV media player.";
    package = mkPkgOpt defaultMpv "Package providing mpv";

    config = mkAttrsOpt "MPV configuration options.";
    scripts = mkPkgsOpt "MPV scripts";
  };

  config = {
    user.home.programs.mpv = {
      inherit (cfg) enable package scripts;

      config = mkMerge [cfg.config mpvDefaultConfig];
    };
  };
}
