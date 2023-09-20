{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  inherit (builtins) fetchTarball;

  # TODO: move this to a overlay.
  proton-ge = let
    baseUrl = "https://github.com/GloriousEggroll/proton-ge-custom/releases/download";
    name = "GE-Proton";
    version = "8-13";
    releaseName = "${name}${version}";
  in
    fetchTarball {
      url = "${baseUrl}/${releaseName}/${releaseName}.tar.gz";
      sha256 = "sha256:0nj7m55hag0cvjs40lfsj3627gqlrknps5xdg8f2m1rmdhfgky65";
    };
in {
  options.modules.games.steam.enable = mkEnableOption "Steam";

  config = mkIf config.modules.games.steam.enable {
    programs.gamemode.enable = true;
    programs.gamemode.settings = {
      general = {
        softrealtime = "auto";
        renice = 18;
      };
      gpu.apply_gpu_optimisations = "accept-responsibility";
    };
    programs.gamescope.enable = true;
    programs.steam.enable = true;
    programs.steam.package = pkgs.steam.override {
      extraEnv.STEAM_EXTRA_COMPAT_TOOLS_PATHS = proton-ge;
    };

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
