{
  config,
  lib,
  options,
  ...
}: let
  inherit (lib.my) mkPathOpt;
  inherit (config.user.xdg) configDir;
  inherit (config) theme;
in {
  options.theme = {
    inherit (options.stylix) fonts polarity;

    wallpaper = mkPathOpt "The image to use as wallpaper";
  };

  config = {
    fonts = {
      enableDefaultFonts = true;
      fontDir.enable = true;

      fontconfig.useEmbeddedBitmaps = true;
    };

    gtk.iconCache.enable = true;
    qt.platformTheme = "gtk2";
    qt.style = "gtk2";

    user.home.extraConfig = {
      gtk = {
        gtk2.configLocation = "${configDir}/gtk-2.0/gtkrc";
      };
      qt = {
        enable = true;
        platformTheme = "gtk";
      };
    };

    stylix = {
      inherit (theme) fonts polarity;
      image = theme.wallpaper;
    };
  };
}
