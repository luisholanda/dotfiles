{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkOption types;
  inherit (lib.my) mkPkgOpt mkStrOpt;
  inherit (config.user.xdg) configDir;
  inherit (config) theme;

  mkNamedPackageOpt = description:
    mkOption {
      inherit description;
      type = types.submodule {
        options = {
          package = mkPkgOpt null "The package to use for this theme";
          name = mkStrOpt "The name of the theme";
        };
      };
    };
in {
  options.theme = {
    active = mkStrOpt "The theme to use";
    cursorTheme = mkNamedPackageOpt "The cursor theme to use";
    iconTheme = mkNamedPackageOpt "The icon theme to use";
    gtkTheme = mkNamedPackageOpt "The GTK theme to use";
  };

  config = {
    gtk.iconCache.enable = true;
    qt.platformTheme = "gtk2";
    qt.style = "gtk2";

    user.home.extraConfig = {
      gtk = {
        inherit (theme) iconTheme;
        enable = true;
        cursorTheme = {
          inherit (theme.cursorTheme) package name;
          size = 16;
        };
        theme = theme.gtkTheme;
        gtk2.configLocation = "${configDir}/gtk-2.0/gtkrc";
      };
      qt = {
        enable = true;
        platformTheme = "gtk";
      };
    };

    user.xdg.configFile."xtheme.init" = {
      text = ''cat ${configDir}/xtheme/* | ${pkgs.xorg.xrdb}/bin/xrdb -load'';
      executable = true;
    };
  };
}
