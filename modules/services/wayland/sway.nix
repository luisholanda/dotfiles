{ config, lib, pkgs, ... }:
let
  inherit (lib) mkOption types mkMerge mkIf listToAttrs makeBinPath;
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

  config = mkMerge [
    (let
      a = config.modules.programs.alacritty;
    in mkIf a.enable {
      user.home.extraConfig.wayland.windowManager.sway.config.terminal = "${makeBinPath [a.package]}/alacritty";
    })

    {
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

          keybindings = {
            "${modifier}+v" = "split toggle";
          } // cfg.config.keybindings;

          window.hideEdgeBorders = "smart";
          workspaceAutoBackAndForth = true;
        };
      };
    }
  ];
}
