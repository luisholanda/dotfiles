{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkForce;
  inherit (config.theme) colors;
in {
  config = {
    modules.services.sway.extraConfig.bars = mkForce [
      {
        mode = "dock";
        hiddenState = "hide";
        position = "bottom";
        workspaceButtons = true;
        workspaceNumbers = true;
        statusCommand = "${pkgs.i3status}/bin/i3status";
        fonts = {
          names = [config.theme.fonts.family.monospace];
          size = config.user.home.extraConfig.wayland.windowManager.sway.config.fonts.size;
        };
        trayOutput = "primary";
        colors = with colors; {
          background = background.hex;
          statusline = foreground.hex;
          separator = selection.hex;
          focusedWorkspace = rec {
            border = selection.hex;
            background = border;
            text = foreground.hex;
          };
          activeWorkspace = {
            border = background.hex;
            background = selection.hex;
            text = foreground.hex;
          };
          inactiveWorkspace = {
            border = background.hex;
            background = background.hex;
            text = "#BFBFBF";
          };
          urgentWorkspace = rec {
            border = normal.red.hex;
            background = border;
            text = foreground.hex;
          };
          bindingMode = rec {
            border = normal.red.hex;
            background = border;
            text = foreground.hex;
          };
        };
      }
    ];
    modules.services.sway.extraConfig.colors = with colors; {
      background = background.hex;
      focused = rec {
        border = bright.black.hex;
        background = border;
        text = foreground.hex;
        indicator = border;
        childBorder = border;
      };
      focusedInactive = rec {
        border = selection.hex;
        background = border;
        text = foreground.hex;
        indicator = border;
        childBorder = border;
      };
      unfocused = {
        border = background.hex;
        background = background.hex;
        text = "#BFBFBF";
        indicator = background.hex;
        childBorder = background.hex;
      };
      urgent = rec {
        border = selection.hex;
        background = normal.red.hex;
        text = foreground.hex;
        indicator = background;
        childBorder = background;
      };
      placeholder = {
        border = background.hex;
        background = background.hex;
        text = foreground.hex;
        indicator = background.hex;
        childBorder = background.hex;
      };
    };
  };
}
