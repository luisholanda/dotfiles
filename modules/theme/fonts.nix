{ config, lib, pkgs, ... }:
let
  inherit (lib) mkAliasDefinitions mkOption types isList optional;

  oneOrListOfStr = either str (listOf str);

  cfg = config.theme.fonts;
  toList = f: if isList f then f else [ f ];
in {
  options.theme.fonts = with types; {
    family = mkOption {
      description = "System-wide font families.";
      type = submodule {
        emoji = mkOption {
          type = oneOrListOfStr;
          example = "Noto Color Emoji";
          default = "Noto Color Emoji";
          description = "System-wide emoji font(s).";
        };
        monospace = mkOption {
          type = oneOrListOfStr;
          example = "DejaVu Sans Mono";
          description = "System-wide monospace font(s).";
        };
        sansSerif = mkOption {
          type = oneOrListOfStr;
          example = "DejaVu Sans";
          description = "System-wide sans serif font(s).";
        };
        serif = mkOption {
          type = oneOrListOfStr;
          example = "DejaVu Serif";
          description = "System-wide serif font(s).";
        };
      };
    };

    size = {
      ui = mkOption {
        type = ints.u8;
        example = 10;
        description = "UI text font size, in points";
      };

      text = mkOption {
        type = ints.u8;
        example = 10;
        description = "Normal text font size, in points";
      };
    };

    packages = mkOption {
      description = "Fonts packages to install.";
      type = listOf package;
    };

    nerdfonts = mkOption {
      description = "Nerd font patches fonts to install.";
      type = listOf str;
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
        enabledNF = pkgs.nerdfonts.override { fonts = cfg.nerdfonts; };
      in cfg.packages ++ optional (cfg.nerdfonts != []) enabledNF;
    };
  };
}
