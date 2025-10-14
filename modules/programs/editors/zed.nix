{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption;

  zed = lib.my.addToPath pkgs.unstable.zed-editor config.modules.editors.extraPackages;
in {
  options.modules.editors.zed.enable = mkEnableOption "Enable the Zed text editor configuration.";

  config.user = lib.mkIf config.modules.editors.zed.enable {
    packages = [zed];
  };
}
