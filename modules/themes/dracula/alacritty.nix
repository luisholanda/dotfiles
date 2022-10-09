{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (config.theme) colors;
in {
  config = mkIf config.theme.dracula.active {
    user.home.programs.alacritty.settings.colors = with colors; rec {
      cursor = {
        text = "CellBackground";
        cursor = "CellForeground";
      };
      vim_mode_cursor = cursor;

      primary.bright_foreground = "#FFFFFF";

      search = {
        matches = {
          foreground = selection.hex;
          background = normal.green.hex;
        };
        focused_match = {
          foreground = selection.hex;
          background = "#FFB86C";
        };
        bar = {
          background = background.hex;
          foreground = foreground.hex;
        };
      };

      hints = {
        start = {
          foreground = background.hex;
          background = normal.yellow.hex;
        };
        end = {
          foreground = normal.yellow.hex;
          background = background.hex;
        };
      };

      line_indicator = {
        foreground = "None";
        background = "None";
      };
      selection = {
        text = "CellForeground";
        background = selection.hex;
      };
    };
  };
}
