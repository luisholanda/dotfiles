{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;

  colors = config.theme.colors;
in {
  config = mkIf config.theme.dracula.active {
    modules.programs.kitty.extraSettings = with colors; {
      active_tab_foreground = background.hex;
      active_tab_background = foreground.hex;

      cursor = foreground.hex;
      cursor_text_color = background.hex;

      inactive_tab_foreground = background.hex;
      inactive_tab_background = bright.black.hex;

      mark1_foreground = background.hex;
      mark1_background = normal.red.hex;

      active_border_color = foreground.hex;
      inactive_border_color = bright.black.hex;
    };
  };
}
