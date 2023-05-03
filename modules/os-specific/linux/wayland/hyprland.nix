{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkDefault mkEnableOption;
  inherit (config.host.hardware.gpu) isNVIDIA;
  inherit (config.lib.stylix) colors;

  active = colors.base0A;
  inactive = colors.base03;
in {
  options.modules.services.hyprland.enable = mkEnableOption "hyprland";

  config = mkIf config.modules.services.hyprland.enable {
    programs.hyprland = {
      enable = true;
      nvidiaPatches = isNVIDIA;
      xwayland.enable = true;
    };

    services.xserver.displayManager.defaultSession = mkDefault "hyprland";

    user.xdg.configFile."hypr/hyprland.conf".text = ''
      source = ${config.dotfiles.configDir}/hyprland.conf

      exec-once = systemctl start --user waybar
      exec = ${pkgs.swaybg}/bin/swaybg -m fill -i ${config.theme.wallpaper}

      general {
        col.active_border = rgb(${active})
        col.inactive_border = rgb(${inactive})
        col.group_border = rgb(${inactive})
        col.group_border_active = rgb(${active})
      }
    '';
  };
}
