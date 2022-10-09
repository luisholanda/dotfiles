{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkOption types isList optional;

  oneOrListOfStr = with types; either str (listOf str);

  cfg = config.theme.fonts;
  toList = f:
    if isList f
    then f
    else [f];
in {
  options.theme.fonts = with types; {
    family = {
      emoji = mkOption {
        type = oneOrListOfStr;
        example = "Noto Color Emoji";
        default = "Noto Color Emoji";
        description = "System-wide emoji font(s).";
      };
      monospace = mkOption {
        type = oneOrListOfStr;
        example = "DejaVu Sans Mono";
        default = "DejaVu Sans Mono";
        description = "System-wide monospace font(s).";
      };
      sansSerif = mkOption {
        type = oneOrListOfStr;
        example = "DejaVu Sans";
        default = "DejaVu Sans";
        description = "System-wide sans serif font(s).";
      };
      serif = mkOption {
        type = oneOrListOfStr;
        example = "DejaVu Serif";
        default = "DejaVu Serif";
        description = "System-wide serif font(s).";
      };
    };

    size = {
      ui = mkOption {
        type = float;
        example = 10.0;
        description = "UI text font size, in points";
      };

      text = mkOption {
        type = float;
        example = 10.0;
        description = "Normal text font size, in points";
      };
    };

    packages = mkOption {
      description = "Fonts packages to install.";
      type = listOf package;
      default = [];
    };

    nerdfonts = mkOption {
      description = "Nerd font patches fonts to install.";
      type = listOf str;
      default = [];
    };
  };

  config = {
    fonts = {
      # TODO: Maybe we should drop this and list the specific fonts we want?
      enableDefaultFonts = true;
      fontDir.enable = true;

      fontconfig = {
        useEmbeddedBitmaps = true;
        defaultFonts = {
          emoji = toList cfg.family.emoji;
          monospace = toList cfg.family.monospace;
          sansSerif = toList cfg.family.sansSerif;
          serif = toList cfg.family.serif;
        };
      };

      fonts = let
        enabledNF = pkgs.nerdfonts.override {fonts = cfg.nerdfonts;};
      in
        cfg.packages ++ optional (cfg.nerdfonts != []) enabledNF;
    };

    user.xdg.configFile."xtheme/05-fonts".text = let
      mono =
        if builtins.isList cfg.family.monospace
        then builtins.head cfg.family.monospace
        else cfg.family.monospace;
    in ''
      *.font: xft:${mono}:pixelsize=${toString (cfg.size.text)}
      Emacs.font: ${mono}:pixelsize=${toString (cfg.size.text)}
    '';

    user.home.extraConfig.gtk.font = {
      name = cfg.family.sansSerif;
      size = cfg.size.ui;
    };
  };
}
