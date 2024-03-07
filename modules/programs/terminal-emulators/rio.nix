{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.my) mkEnableOpt;
  inherit (config.lib.stylix) colors;
  inherit (config.theme) fonts;

  cfg = config.modules.programs.rio;
in {
  options.modules.programs.rio.enable = mkEnableOpt "Enable the use of rio terminal emulator.";

  config = mkIf cfg.enable {
    user.terminalCmd = "${lib.makeBinPath [pkgs.rio]}/rio";
    user.home.programs.rio = {
      enable = true;
      settings = {
        cursor = "|";
        blinking-cursor = true;
        hide-cursor-when-typing = true;
        window = {
          background-opacity = 0.6;
          blur = true;
        };
        renderer = {
          performance = "High";
          disable-renderer-when-unfocused = true;
        };
        fonts = {
          family = fonts.monospace.name;
          size = fonts.sizes.terminal;
          extras = [
            {family = fonts.emoji.name;}
          ];
        };
        keyboard.use-kitty-keyboard-protocol = true;
        navigation.mode = "BottomTab";
        colors = {
          background = colors.base00;
          foreground = colors.base05;
          cursor = colors.base04;
          tabs = colors.base01;
          tabs-active = colors.base04;
          green = colors.base0B;
          red = colors.base08;
          blue = colors.base0D;
          yellow = colors.base0A;
        };
      };
    };
  };
}
