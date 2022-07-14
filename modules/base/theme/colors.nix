{
  options,
  config,
  lib,
  ...
}: let
  inherit (lib) listToAttrs;
  inherit (lib.my) mkColorOpt;

  cfg = config.theme.colors;

  xResColors = ["black" "red" "green" "yellow" "blue" "magenta" "cyan" "white"];
  xResourceColorsOpts = let
    colorToOpt = c:
      mkColorOpt {
        description = "The color to be considered as ${c} by other programs.";
      };
    colorToOptPair = c: {
      name = c;
      value = colorToOpt c;
    };
  in
    builtins.listToAttrs (map colorToOptPair xResColors);
in {
  options.theme.colors = {
    background = mkColorOpt {
      description = "The color to be used for the background of programs.";
    };
    foreground = mkColorOpt {
      description = "The color to be used for the foreground (e.g. text) of programs.";
    };
    selection = mkColorOpt {
      description = "The color to be used for selections.";
    };
    currentLine = mkColorOpt {
      description = "The color to be used for the background of the current line.";
    };

    normal = xResourceColorsOpts;
    bright = xResourceColorsOpts;
    error = mkColorOpt {
      description = "The color to be used in error dialogs.";
      default = cfg.normal.red;
    };
    warning = mkColorOpt {
      description = "The color to be used in warning dialogs.";
      default = cfg.normal.yellow;
    };
  };

  config = {
    console.colors =
      (map (c: cfg.normal."${c}".plain) xResColors)
      ++ (map (c: cfg.bright."${c}".plain) xResColors);

    user.xdg.configFile = {
      "xtheme/00-init".text = with cfg; let
        normalColors = with normal; ''
          #define blk ${black.hex}
          #define red ${red.hex}
          #define grn ${green.hex}
          #define ylw ${yellow.hex}
          #define blu ${blue.hex}
          #define mag ${magenta.hex}
          #define cyn ${cyan.hex}
          #define wht ${white.hex}
        '';

        brightColors = with bright; ''
          #define bblk ${black.hex}
          #define bred ${red.hex}
          #define bgrn ${green.hex}
          #define bylw ${yellow.hex}
          #define bblu ${blue.hex}
          #define bmag ${magenta.hex}
          #define bcyn ${cyan.hex}
          #define bwht ${white.hex}
        '';
      in ''
        #define bg ${background.hex}
        #define fg ${foreground.hex}

        ${normalColors}
        ${brightColors}
      '';
    };
  };
}
