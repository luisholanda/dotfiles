{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkForce mkDefault mkMerge optionalAttrs;
  inherit (lib.my) isLinux;
  inherit (config.user.xdg) configDir;
in {
  config = mkMerge [
    {
      fonts.packages = with pkgs; [
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif
      ];

      user.home.extraConfig = {
        gtk = {
          gtk2.configLocation = "${configDir}/gtk-2.0/gtkrc";
        };
        qt.enable = true;
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
    }
    (optionalAttrs isLinux {
      fonts = {
        fontDir.enable = true;

        fontconfig.useEmbeddedBitmaps = true;
      };

      gtk.iconCache.enable = true;
      qt.style = mkForce "gtk2";
    })
  ];
}
