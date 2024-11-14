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
    programs.gamescope.package = pkgs.gamescope_git;
    programs.gamescope.args = ["--rt" "--immediate-flips" "--adaptive-sync"];

    programs.steam.enable = true;
    programs.steam.extraCompatPackages = with pkgs; [proton-ge-custom];
    programs.steam.package = pkgs.steam;

    user.groups = ["gamemode"];
  };
}
