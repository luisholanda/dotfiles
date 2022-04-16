{
  options,
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) types mkOption listToAttrs;
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
    normal = xResourceColorsOpts;
    bright = xResourceColorsOpts;
  };

  config = {
    console.colors =
      (map (c: cfg.normal."${c}".plain) xResColors)
      ++ (map (c: cfg.bright."${c}".plain) xResColors);
  };
}
