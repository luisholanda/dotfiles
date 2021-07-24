{ options, config, lib, pkgs, ... }:
let
  inherit (lib) types mkOption listToAttrs;
  inherit (lib.my) mkColorOpt;

  cfg = config.colors;

  xResColors = ["black" "red" "green" "yellow" "blue" "magenta" "cyan" "white"];
  mkXresourceColorsOpts =
    let
      colorToOpt = c: mkColorOpt {
        description = "The color to be considered as ${c} by other programs.";
      };
      colorToOptPair = c: { name = c; value = colorToOpt c; };
    in description: mkOption {
      inherit description;
      type = with types; submodule (map colorToOptPair xResColors);
    };
in {
  options.theme.colors = mkOption {
    description = "Controls the colors used by the system.";
    type = with lib.types; submodule {
      background = mkColorOpt {
        description = "The color to be used for the background of programs.";
      };
      foreground = mkColorOpt {
        description = "The color to be used for the foreground (e.g. text) of programs.";
      };
      normal = mkXresourceColorsOpts "The colors to be used normally.";
      bright = mkXresourceColorsOpts "The colors to be used as bright (or bold)";
    };
  };

  config = {
    console.colors = (map (c: cfg.normal."${c}".plain) xResColors)
      ++ (map (c: cfg.bright."${c}".plain) xResColors);
  };
}
