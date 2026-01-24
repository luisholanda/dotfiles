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
    programs.steam.extraCompatPackages = with pkgs.unstable; [proton-ge-bin];
    programs.steam.package = pkgs.steam;

    programs.steam.protontricks.enable = true;

    user.groups = ["gamemode"];

    boot.kernelModules = ["ntsync"];
  };
}
