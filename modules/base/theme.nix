{
  config,
  lib,
  options,
  pkgs,
  ...
}: let
  inherit (lib) mkDefault;
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
      enableDefaultPackages = true;
      fontDir.enable = true;

      fontconfig.useEmbeddedBitmaps = true;

      fonts = with pkgs; [
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif
      ];
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

    theme.fonts = {
      serif = mkDefault {
        package = pkgs.noto-fonts-lgc-plus;
        name = "Noto Serif";
      };
      sansSerif = mkDefault {
        package = pkgs.noto-fonts-lgc-plus;
        name = "Noto Sans";
      };
      emoji = mkDefault {
        package = pkgs.noto-fonts-emoji-blob-bin;
        name = "Noto Color Emoji";
      };
      monospace = mkDefault {
        package = pkgs.pragmasevka;
        name = "Pragmasevka Nerd Font";
      };
      sizes.desktop = mkDefault 12;
    };
  };
}
