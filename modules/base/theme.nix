{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkDefault;
  inherit (config.user.xdg) configDir;
  inherit (config) theme;
in {
  config = {
    fonts = {
      enableDefaultPackages = true;
      fontDir.enable = true;

      fontconfig.useEmbeddedBitmaps = true;

      packages = with pkgs; [
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif
      ];
    };

    gtk.iconCache.enable = true;
    qt.platformTheme.name = "gtk2";
    qt.style = "gtk2";

    user.home.extraConfig = {
      gtk = {
        gtk2.configLocation = "${configDir}/gtk-2.0/gtkrc";
      };
      qt = {
        enable = true;
        platformTheme.name = "gtk";
      };
    };

    stylix = {
      enable = true;

      fonts = {
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
  };
}
