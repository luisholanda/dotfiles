{ config, lib, pkgs, ... }:
let
  inherit (lib) mkOption mkOptionDefault types mkMerge mkIf listToAttrs makeBinPath;
  inherit (lib.my) mkEnableOpt mkColorHexValueOpt;

  mkColor = description: mkColorHexValueOpt { inherit description; };
  colorSubmodule = types.submodule {
    options = {
      background = mkColor "Background color of the window.";
      border = mkColor "Border color of the window.";
      childBorder = mkColor "Border color of child windows.";
      indicator = mkColor "Split indicator color.";
    };
  };

  modifier = "Mod4";
  cfg = config.modules.services.sway;
in {
  options.modules.services.sway = {
    enable = mkEnableOpt "Enable Sway WM";

    config = {
      gaps = {
        inner = mkOption {
          type = types.ints.u8;
          default = 0;
          description = "Gaps between windows";
        };
        outer = mkOption {
          type = types.ints.u8;
          default = 0;
          description = "Gaps between windows and screen border";
        };
      };

      input = let
        libinputOpt = mkOption {
          type = types.attrsOf types.str;
          default = {};
          description = "Libinput configuration";
        };
      in {
        mouse = libinputOpt;
        keyboard = libinputOpt;
        penTablet = libinputOpt;
      };

      keybindings = mkOption {
        type = types.attrsOf types.str;
        default = {};
        description = "Extra keybindings";
      };
    };
  };

  config = {
    # Environment variable required to make sway work on qemu
    user.sessionCmd = "env WLR_RENDERER_ALLOW_SOFTWARE=1 sway";
    user.home.extraConfig.wayland.windowManager.sway = {
      enable = cfg.enable;

      config = {
        inherit modifier;

        gaps = {
          outer = cfg.config.gaps.outer;
          inner = cfg.config.gaps.inner;
          smartGaps = true;
        };

        input = {
          "type:keyboard" = {
            repeat_delay = "150";
            repeat_rate = "30";
            xkb_layout = "us";
            xkb_variant = "intl";
          } // cfg.config.input.keyboard;
          "type:pointer" = {
            accel_profile = "adaptive";
            natural_scroll = "enabled";
          } // cfg.config.input.mouse;
          "type:tablet_tool" = cfg.config.input.penTablet;
        };

        keybindings = let
          customKeybindings = {
          "${modifier}+v" = "split toggle";
          } // cfg.config.keybindings;
        in mkOptionDefault customKeybindings;

        terminal = let
          a = config.modules.programs.alacritty;
        in mkIf a.enable "${makeBinPath [a.package]}/alacritty";

        window.hideEdgeBorders = "smart";
        workspaceAutoBackAndForth = true;
      };
    };
  };
}
