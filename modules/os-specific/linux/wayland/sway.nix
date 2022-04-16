{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkOption mkOptionDefault mkDefault types mkMerge mkIf listToAttrs makeBinPath;
  inherit (lib.my) mkEnableOpt mkColorHexValueOpt mkPkgsOpt;

  mkColor = description: mkColorHexValueOpt {inherit description;};
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
  hmCfg = config.user.home.extraConfig.wayland.windowManager.sway;

  sway =
    (pkgs.sway.override {
      inherit (hmCfg) extraSessionCommands;
      withBaseWrapper = true;
      withGtkWrapper = true;
    })
    .overrideAttrs (old: {
      buildInputs = old.buildInputs ++ cfg.extraPackages;
    });
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

      startup = mkOption {
        type = types.listOf types.attr;
        default = [];
        description = "Startup code";
      };
    };

    extraPackages = mkPkgsOpt "sway";
  };

  config = {
    user.sessionCmd = "exec ${sway}/bin/sway";
    user.home.services.kanshi.enable = cfg.enable;
    user.home.extraConfig.wayland.windowManager.sway = {
      inherit (cfg) enable;

      package = sway;

      config = {
        inherit modifier;

        gaps = {
          inherit (cfg.config.gaps) inner outer;
          smartGaps = true;
        };

        input = {
          "type:keyboard" =
            {
              repeat_delay = "150";
              repeat_rate = "30";
              xkb_layout = "us";
              xkb_variant = "intl";
            }
            // cfg.config.input.keyboard;
          "type:pointer" =
            {
              accel_profile = "adaptive";
              natural_scroll = "enabled";
            }
            // cfg.config.input.mouse;
          "type:tablet_tool" = cfg.config.input.penTablet;
        };

        fonts = {
          names = config.fonts.fontconfig.defaultFonts.sansSerif ++ config.fonts.fontconfig.defaultFonts.emoji;
          size = config.theme.fonts.size.ui;
        };

        keybindings = let
          customKeybindings =
            {
              "${modifier}+v" = "split toggle";
            }
            // cfg.config.keybindings;
        in
          mkOptionDefault customKeybindings;

        terminal = config.user.terminalCmd;

        window.hideEdgeBorders = "smart";
        workspaceAutoBackAndForth = true;
      };

      extraSessionCommands = ''
        export SDL_VIDEODRIVER=wayland
        export QT_QPA_PLATFORM=wayland
        export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
        export _JAVA_AWT_WM_NOREPARENTING=1
        export MOZ_ENABLE_WAYLAND=1
        export XDG_CURRENT_DESKTOP=sway
        # Environment variable required to make sway work on qemu
        export WLR_RENDERER_ALLOW_SOFTWARE=1
      '';

      wrapperFeatures.gtk = true;
    };
  };
}
