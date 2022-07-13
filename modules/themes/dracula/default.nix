{ config, lib, pkgs, ... }: let
  inherit (lib) mkIf;
  inherit (lib.my) mkColor;

  thisThemeName = "dracula";
  activeThemeName = config.theme.active;
in {
  config = mkIf (thisThemeName == activeThemeName) {
    theme.colors = {
      background = mkColor "#282A36";
      foreground = mkColor "#F8F8F2";
      selection = mkColor "#44475A";
      currentLine = mkColor "#44475A";
      normal = {
        black = mkColor "#21222c";
        red = mkColor "#ff5555";
        green = mkColor "#50fa7b";
        yellow = mkColor "#f1fa8c";
        blue = mkColor "#bd93f9";
        magenta = mkColor "#ff79c6";
        cyan = mkColor "#8be9fd";
        white = mkColor "#f8f8f2";
      };
      bright = {
        black = mkColor "#6272a4";
        red = mkColor "#ff6e6e";
        green = mkColor "#69ff94";
        yellow = mkColor "#ffffa5";
        blue = mkColor "#d6acff";
        magenta = mkColor "#ff92df";
        cyan = mkColor "#a4ffff";
        white = mkColor "#ffffff";
      };
    };

    theme.fonts = {
      family = {
        emoji = "Noto Color Emoji";
        monospace = "Iosevka";
        sansSerif = "Noto Sans";
        serif = "Noto Serif";
      };

      size = { ui = 12.0; text = 12.0; };

      packages = with pkgs; [ iosevka-custom ];
    };
  };
}
