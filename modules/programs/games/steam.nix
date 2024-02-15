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
    chaotic.steam.extraCompatPackages = with pkgs; [proton-ge-custom];

    user.home.extraConfig.systemd.user.services.steam = rec {
      Unit = {
        Description = "A digital distribution platform";
        After = ["graphical-session.target"];
      };

      Service = {
        ExecStart = "${pkgs.steam}/bin/steam -silent";
        ExecStop = "${pkgs.coreutils}/bin/kill -SIGUSR2 $MAINPID";
        Restart = "on-failure";
        KillMode = "mixed";
      };

      Install.WantedBy = Unit.After;
    };
  };
}
