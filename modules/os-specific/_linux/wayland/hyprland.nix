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

  startUserService = service: "exec-once = systemctl start --user ${service}";
in {
  options.modules.services.hyprland.enable = mkEnableOption "hyprland";

  config = mkIf config.modules.services.hyprland.enable {
    environment.systemPackages = with pkgs; [bemenu];

    programs.hyprland = {
      enable = true;
      enableNvidiaPatches = isNVIDIA;
      xwayland.enable = true;
    };

    services.xserver.displayManager.defaultSession = mkDefault "hyprland";

    user.xdg.configFile."hypr/hyprland.conf".text = ''
      source = ${config.dotfiles.configDir}/hyprland.conf

      ${startUserService "waybar"}

      exec-once = ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
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
