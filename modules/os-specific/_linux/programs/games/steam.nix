{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
in {
  options.modules.games.steam.enable = mkEnableOption "Steam";

  config = mkIf config.modules.games.steam.enable {
    programs.gamemode.enable = true;
    programs.gamemode.settings = {
      general = {
        softrealtime = "auto";
        renice = 18;
      };
      gpu = {
        apply_gpu_optimisations = "accept-responsibility";
        amd_performance_level = "high";
      };
    };

    programs.gamescope.enable = true;
    programs.gamescope.capSysNice = false;
    programs.gamescope.package = pkgs.unstable.gamescope;
    programs.gamescope.args = ["--rt" "--immediate-flips" "--adaptive-sync"];

    programs.steam.enable = true;
    programs.steam.extraCompatPackages = with pkgs.unstable; [proton-ge-bin pkgs.proton-cachyos];
    programs.steam.package = pkgs.steam.override {
      extraEnv = {
        PROTON_ENABLE_WAYLAND = 1;
        PROTON_DXVK_LOWLATENCY = 1;
        PROTON_FSR4_UPGRADE = 1;
        DXVK_HDR = 1;
        LOW_LATENCY_LAYER = 1;
        PROTON_USE_OPTISCALER = 1;
      };
    };
    programs.steam.extraPackages = with pkgs; [
      libxcrypt
      libmspack
      libpng
      libpulseaudio
      libvorbis
      stdenv.cc.cc.lib
      libkrb5
      keyutils
      gamemode.lib
      (pkgs.runCommandLocal "libxcrypt-1" {src = libxcrypt;} ''
        mkdir -p $out/lib
        cp $src/lib/libcrypt.so $out/lib/libcrypt.so.1
      '')
    ];

    programs.steam.protontricks.enable = true;

    user.groups = ["gamemode"];

    boot.kernelModules = ["ntsync"];
  };
}
