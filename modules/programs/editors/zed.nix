{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption;

  baseZed = lib.my.addToPath pkgs.unstable.zed-editor config.modules.editors.extraPackages;

  zed = pkgs.buildFHSEnv {
    name = "zed";
    runScript = "${baseZed}/bin/zed";
  };
in {
  options.modules.editors.zed.enable = mkEnableOption "Enable the Zed text editor configuration.";

  config.user = lib.mkIf config.modules.editors.zed.enable {
    packages = [zed];
  };
}
