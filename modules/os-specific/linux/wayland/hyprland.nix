{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkDefault mkEnableOption;
  inherit (config.host.hardware.gpu) isNVIDIA;
in {
  options.modules.services.hyprland.enable = mkEnableOption "hyprland";

  config = mkIf config.modules.services.hyprland.enable {
    programs.hyprland = {
      enable = true;
      nvidiaPatches = isNVIDIA;
      xwayland.enable = true;
      #xwayland.hidpi = true;
    };

    services.xserver.displayManager.defaultSession = mkDefault "hyprland";

    user.xdg.configFile."hypr/hyprland.conf".source = "${config.dotfiles.configDir}/hyprland.conf";
  };
}
