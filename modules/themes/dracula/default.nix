{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.my) mkBoolOpt mkColor;

  draculaIcons = pkgs.stdenv.mkDerivation {
    pname = "dracula-icon-theme";
    version = "3.0";

    src = builtins.fetchurl {
      url = "https://github.com/dracula/gtk/files/5214870/Dracula.zip";
      sha256 = "sha256:1dnc1g1qw9r7glilw1gg11b4f6icfxckkjrj5rhmzzmlxwcjib9k";
    };

    nativeBuildInputs = with pkgs; [unzip gtk3];

    propagatedBuildInputs = with pkgs; [
      gnome.adwaita-icon-theme
      gnome-icon-theme
      hicolor-icon-theme
    ];

    dontDropIconThemeCahce = true;

    installPhase = ''
      runHook preInstall

      mkdir -p "$out/share/icons/Dracula"

      mv * "$out/share/icons/Dracula/"

      runHook postInstall
    '';

    postFixup = "gtk-update-icon-cache $out/share/icons/Dracula";
  };
in {
  options.theme.dracula.active =
    mkBoolOpt
    (config.theme.active == "dracula")
    "Is this theme active?";

  config = mkIf config.theme.dracula.active {
    theme = rec {
      cursorTheme = gtkTheme;
      gtkTheme = {
        package = pkgs.dracula-theme;
        name = "Dracula";
      };
      iconTheme = {
        package = draculaIcons;
        name = "Dracula";
      };
    };
    theme.colors = {
      background = mkColor "#282A36";
      foreground = mkColor "#F8F8F2";
      selection = mkColor "#44475A";
      currentLine = mkColor "#44475A";
      normal = {
        black = mkColor "#21222C";
        red = mkColor "#FF5555";
        green = mkColor "#50FA7B";
        yellow = mkColor "#F1FA8C";
        blue = mkColor "#BD93F9";
        magenta = mkColor "#FF79C6";
        cyan = mkColor "#8BE9FD";
        white = mkColor "#F8F8F2";
      };
      bright = {
        black = mkColor "#6272A4";
        red = mkColor "#FF6E6E";
        green = mkColor "#69FF94";
        yellow = mkColor "#FFFFA5";
        blue = mkColor "#D6ACFF";
        magenta = mkColor "#FF92DF";
        cyan = mkColor "#A4FFFF";
        white = mkColor "#FFFFFF";
      };
    };

    theme.fonts = {
      family = {
        emoji = "Noto Color Emoji";
        monospace = "Iosevka Custom";
        sansSerif = "Noto Sans";
        serif = "Noto Serif";
      };

      size = {
        ui = 12.0;
        text = 12.0;
      };

      packages = with pkgs; [
        iosevka-custom
        font-awesome
        lmodern
        noto-fonts
        noto-fonts-cjk
        noto-fonts-emoji
      ];
    };
  };
}
