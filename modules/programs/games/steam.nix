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
    programs.gamescope.package = pkgs.gamescope_git;
    programs.steam.enable = true;
    programs.steam.extraCompatPackages = with pkgs; [proton-ge-custom];
    programs.steam.gamescopeSession.enable = true;
    programs.steam.package = pkgs.unstable.steam;
  };
}
