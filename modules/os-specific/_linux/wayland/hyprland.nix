{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkDefault mkEnableOption;
  inherit (config.lib.stylix) colors;

  active = colors.base0A;
  inactive = colors.base03;

  screenshot = pkgs.writeScriptBin "screenshot" ''
    #!${pkgs.bash}/bin/bash
    filename="screenshot-$(date +%F-%T)"
    ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" ~/Screenshots/$filename.png
  '';

  startUserService = service: "exec-once = systemctl start --user ${service}";
in {
  options.modules.services.hyprland.enable = mkEnableOption "hyprland";

  config = mkIf config.modules.services.hyprland.enable {
    environment.systemPackages = with pkgs; [bemenu screenshot wl-clipboard];

    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };

    services.xserver.displayManager.defaultSession = mkDefault "hyprland";

    user.sessionVariables.NIXOS_OZONE_WL = 1;
    user.xdg.configFile."hypr/hyprland.conf".text = ''
      source = ${config.dotfiles.configDir}/hyprland.conf

      ${startUserService "waybar"}

      exec-once = ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
      exec = ${pkgs.swaybg}/bin/swaybg -m fill -i ${config.theme.wallpaper}

      general {
        col.active_border = rgb(${active})
        col.inactive_border = rgb(${inactive})
      }
    '';
  };
}
