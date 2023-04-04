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
    version = "7-53";
    releaseName = "${name}${version}";
  in
    fetchTarball {
      url = "${baseUrl}/${releaseName}/${releaseName}.tar.gz";
      sha256 = "sha256:1cb0f7y4qfbpcg70fcmcrgd15xmpl18iljh5nw45c5rzvl6v0hm0";
    };
in {
  options.modules.games.steam.enable = mkEnableOption "Steam";

  config = mkIf config.modules.games.steam.enable {
    programs.gamemode.enable = true;
    programs.steam.enable = true;

    environment.sessionVariables.STEAM_EXTRA_COMPAT_TOOLS_PATHS = proton-ge;

    environment.systemPackages = with pkgs; [gamescope];
  };
}
