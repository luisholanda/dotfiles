{ config, lib,
 pkgs, ... }: let
  inherit (lib) mkIf mkDefault mkOverride mkForce;
  inherit (config.theme) colors;

  /*
# class                 border  bground text    indicator child_border
client.focused          #6272A4 #6272A4 #F8F8F2 #6272A4   #6272A4
client.focused_inactive #44475A #44475A #F8F8F2 #44475A   #44475A
client.unfocused        #282A36 #282A36 #BFBFBF #282A36   #282A36
client.urgent           #44475A #FF5555 #F8F8F2 #FF5555   #FF5555
client.placeholder      #282A36 #282A36 #F8F8F2 #282A36   #282A36
  */
in {
  config = {
    modules.services.sway.extraConfig.bars = mkForce [{
      mode = "dock";
      hiddenState = "hide";
      position = "bottom";
      workspaceButtons = true;
      workspaceNumbers = true;
      statusCommand = "${pkgs.i3status}/bin/i3status";
      fonts = {
        names = [ config.theme.fonts.family.monospace ];
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
    }];
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
