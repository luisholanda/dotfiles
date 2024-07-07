{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  inherit (config.lib.stylix) colors;
  inherit (config.stylix) cursor fonts;

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
      package = pkgs.unstable.hyprland;
      portalPackage = pkgs.unstable.xdg-desktop-portal-hyprland;
      enable = true;
      xwayland.enable = true;
    };

    user.sessionVariables.NIXOS_OZONE_WL = 1;
    user.xdg.configFile."hypr/hyprland.conf".text = ''
      source = ${config.dotfiles.configDir}/hyprland.conf

      exec-once = ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd --all
      exec-once = systemctl --user import-environment QT_QPA_PLATFORMTHEME
      exec = ${pkgs.swaybg}/bin/swaybg -m fill -i ${config.stylix.image}

      exec-once = gsettings set org.gnome.desktop.interface cursor-theme '${cursor.name}'
      exec-once = gsettings set org.gnome.desktop.interface font-theme '${fonts.sansSerif.name}'

      ${startUserService "waybar"}
      ${startUserService "xdg-desktop-portal-hyprland"}

      general {
        col.active_border = rgb(${active})
        col.inactive_border = rgb(${inactive})
      }
    '';
  };
}
