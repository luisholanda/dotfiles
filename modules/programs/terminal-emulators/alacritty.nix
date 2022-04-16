{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkOption types;
  inherit (lib.my) mkEnableOpt;
  inherit (config.theme) colors fonts;

  cfg = config.modules.programs.alacritty;
in {
  options.modules.programs.alacritty = with types; {
    enable = mkEnableOpt "Enable the use of alacritty terminal emulator.";

    package = mkOption {
      description = "The alacritty package to install.";
      type = package;
      default = pkgs.alacritty;
    };

    font.size = mkOption {
      description = "Text's font size.";
      type = ints.u8;
      default = 12;
    };

    window = {
      dynamicTitle = mkOption {
        description = ''
          If the window title should be dynamically changed to the current
          command being run.
        '';
        type = bool;
        default = false;
      };

      dimensions = {
        columns = mkOption {
          description = "N. of columns in the window.";
          default = 80;
          type = ints.unsigned;
        };
        rows = mkOption {
          description = "N. of rows in the window.";
          default = 24;
          type = ints.unsigned;
        };
      };

      padding = {
        x = mkOption {
          default = 0;
          description = "Padding added horizontally to the window.";
          type = ints.u16;
        };
        y = mkOption {
          default = 0;
          description = "Padding added vertically to the window.";
          type = ints.u16;
        };
      };
    };
  };

  config = mkIf cfg.enable {
    user.terminalCmd = "${lib.makeBinPath [cfg.package]}/alacritty";
    user.home.programs.alacritty = {
      inherit (cfg) enable package;

      settings = {
        colors = {
          primary = {
            background = colors.background.xHex;
            foreground = colors.foreground.xHex;
          };

          normal = {
            black = colors.normal.black.xHex;
            red = colors.normal.red.xHex;
            green = colors.normal.green.xHex;
            yellow = colors.normal.yellow.xHex;
            blue = colors.normal.blue.xHex;
            magenta = colors.normal.magenta.xHex;
            cyan = colors.normal.cyan.xHex;
            white = colors.normal.white.xHex;
          };

          bright = {
            black = colors.bright.black.xHex;
            red = colors.bright.red.xHex;
            green = colors.bright.green.xHex;
            yellow = colors.bright.yellow.xHex;
            blue = colors.bright.blue.xHex;
            magenta = colors.bright.magenta.xHex;
            cyan = colors.bright.cyan.xHex;
            white = colors.bright.white.xHex;
          };
        };

        draw_bold_text_with_bright_colors = true;

        font = let
          family = fonts.family.monospace;
          fontWithStyle = style: {inherit family style;};
        in {
          inherit (cfg.font) size;
          normal = fontWithStyle "Normal";
          bold = fontWithStyle "Bold";
          italic = fontWithStyle "Italic";
          bold_italic = fontWithStyle "Bold Italic";

          use_think_strokes = false;
        };

        live_config_reload = true;
        mouse.hide_when_typing = false;
        selection.save_to_clipboard = true;

        window = {
          inherit (cfg.window) padding;

          decorations =
            if pkgs.stdenv.isDarwin
            then "buttonless"
            else "none";
          dimensions = {
            inherit (cfg.window.dimensions) columns rows;
          };

          dynamic_title = cfg.window.dynamicTitle;
          dynamic_padding = true;
          startup_mode = "Maximized";
        };
      };
    };
  };
}
