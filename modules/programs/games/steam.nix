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
    version = "7-43";
    releaseName = "${name}${version}";
  in
    fetchTarball {
      url = "${baseUrl}/${releaseName}/${releaseName}.tar.gz";
      sha256 = "sha256:1qw87ychhx8z5wvzw8w1j0h554mxs9w14glbbn2ywwyhp643h2hb";
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
