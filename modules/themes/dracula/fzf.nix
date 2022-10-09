{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (config.theme.colors) foreground background currentLine normal bright;
in {
  config = mkIf config.theme.dracula.active {
    user.sessionVariables.FZF_DEFAULT_OPTS = builtins.concatStringsSep " " [
      "--color"
      "fg:${foreground.hex},bg:${background.hex},hl:${normal.blue.hex}"
      "--color"
      "fg+:${foreground.hex},bg+:${currentLine.hex},hl+:${normal.blue.hex}"
      "--color"
      "info:#FFB86C,prompt:${normal.green.hex},pointer:${normal.magenta.hex}"
      "--color"
      "marker:${normal.magenta.hex},spinner:#FFB86C,header:${bright.black.hex}"
    ];
  };
}
