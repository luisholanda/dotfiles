{ config, lib, pkgs, ... }:
let
  inherit (lib) mkOption types mkMerge mkIf listToAttrs;
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
  cfg = config.modules.service.sway;
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

      input = listToAttrs (map ({ attr, name }: {
        name = attr;
        value = mkOption {
          type = types.attrsOf types.str;
          default = {};
          description = "Mouse's libinput configuration";
        };
      }) ["mouse" "keyboard" "penTablet"]);

      keybindings = mkOption {
        type = types.attrsOf types.str;
        default = {};
        description = "Extra keybindings";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      user.home.extraConfig.wayland.windowManager.sway = {
        enable = true;

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
              xkb_variant = "int";
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
    (let
      a = config.modules.programs.alacritty;
    in mkIf a.enable {
      user.home.extraConfig.wayland.windowManager.sway = {
        config.terminal = "${a.package}/bin/alacritty";
      };
    })
  ]);
}
