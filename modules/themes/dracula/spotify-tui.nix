{ config, lib, pkgs, ... }: let
  inherit (lib) mkIf;
  inherit (config.theme.colors) foreground normal currentLine;

  yaml = pkgs.formats.yaml {};
in {
  config = mkIf config.theme.dracula.active {
    user.xdg.configFile."spotify-tui/config.yml".source =
      yaml.generate "spotify-tui-config.yml" {
        theme = {
          active = normal.blue.rgb;
          banner = normal.green.rgb;
          error_border = normal.yellow.rgb;
          error_text = foreground.rgb;
          hint = normal.yellow.rgb;
          hovered = "255,184,108";
          inactive = foreground.rgb;
          playbar_background = currentLine.rgb;
          playbar_progress = foreground.rgb;
          playbar_progress_text = foreground.rgb;
          playbar_text = foreground.rgb;
          selected = normal.green.rgb;
          text = foreground.rgb;
          header = foreground.rgb;
        };
      };
  };
}
