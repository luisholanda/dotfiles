{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkOption mkOptionDefault types;
  inherit (lib.my) mkAttrsOpt mkEnableOpt mkPkgsOpt addToPath mkPathOpt;
  inherit (config.user.home.extraConfig) gtk;
  inherit (config.host.hardware) isLaptop;

  modifier = "Mod4";
  cfg = config.modules.services.sway;

  sway = addToPath pkgs.sway (cfg.extraPackages ++ (with pkgs; [swaylock]));

  screenshot = pkgs.writeScriptBin "screenshot" ''
    #!${pkgs.bash}/bin/bash
    filename="screenshot-$(date +%F-%T)"
    ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" ~/Screenshots/$filename.png
  '';

  swaylockCmd = builtins.concatStringsSep " " [
    "swaylock"
    "--daemonize"
  ];

  # TODO: use native wrapper
  swayWrapped = pkgs.writeScriptBin "sway" ''
    export SDL_VIDEODRIVER=wayland
    export QT_QPA_PLATFORM=wayland
    export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
    export QT_WAYLAND_FORCE_DPI=physical
    export _JAVA_AWT_WM_NOREPARENTING=1
    export MOZ_ENABLE_WAYLAND=1
    export XDG_CURRENT_DESKTOP=sway
    export XDG_SESSION_TYPE=wayland
    #export WLR_RENDERER=vulkan
    export WLR_NO_HARDWARE_CURSORS=1

    # Environment variable required to make sway work on qemu
    export WLR_RENDERER_ALLOW_SOFTWARE=1

    ${sway}/bin/sway --unsupported-gpu -D noscanout
  '';
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
        touchpad = libinputOpt;
        keyboard = libinputOpt;
        penTablet = libinputOpt;
      };

      keybindings = mkOption {
        type = types.attrsOf types.str;
        default = {};
        description = "Extra keybindings";
      };

      startup = mkOption {
        type = types.listOf types.attrs;
        default = [];
        description = "Startup code";
      };

      output = mkAttrsOpt "Configure sway output displays";
    };

    extraConfig = mkOption {
      type = types.attrs;
      default = {};
      description = "Extra Sway configuration to pass to home-manager";
    };

    wallpaper = mkPathOpt "Wallpaper to use in Sway";

    extraPackages = mkPkgsOpt "sway";
  };

  config = {
    host.laptop.gestures = let
      do = "${pkgs.ydotool}/bin/ydotool";
      swaymsg = "${pkgs.sway}/bin/swaymsg";
    in
      mkIf isLaptop {
        nextWorkspace = "${swaymsg} workspace next";
        prevWorkspace = "${swaymsg} workspace prev";
        goForward = "${do} key -d 5 158:0 158:1";
        goBack = "${do} key -d 5 159:0 159:1";
      };

    user.sessionCmd = "${swayWrapped}/bin/sway";
    user.packages = [screenshot] ++ (with pkgs; [wl-clipboard]);

    security.pam.services.swaylock = {};

    services.xserver.displayManager.session = [
      {
        manage = "desktop";
        name = "Sway";
        start = ''
          ${swayWrapped}/bin/sway &
          waitPID=$!
        '';
      }
    ];

    #user.home.programs.swaylock.settings = lib.mkAliasDefinitions opts.lock.settings;
    user.home.services.kanshi.enable = cfg.enable;
    user.home.services.swayidle = {
      inherit (cfg) enable;
      events = [
        {
          event = "before-sleep";
          command = "${pkgs.playerctl}/bin/playerctl pause";
        }
        {
          event = "before-sleep";
          command = swaylockCmd;
        }
        {
          event = "lock";
          command = swaylockCmd;
        }
      ];
      timeouts = [
        {
          timeout = 5 * 60;
          command = swaylockCmd;
        }
        {
          timeout = 6 * 60;
          command = "swaymsg 'output * dpms off'";
          resumeCommand = "swaymsg 'output * dpms on'";
        }
      ];
    };

    user.home.extraConfig.wayland.windowManager.sway = {
      inherit (cfg) enable;

      package = sway;

      config =
        cfg.extraConfig
        // {
          inherit modifier;

          output =
            cfg.config.output
            // {
              "*".bg = "${cfg.wallpaper} fill";
            };

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
            "type:touchpad" =
              {
                tap = "enabled";
                natural_scroll = "enabled";
                dwt = "enabled";
              }
              // cfg.config.input.penTablet;
            "type:tablet_tool" = cfg.config.input.penTablet;
          };

          fonts = {
            names = config.fonts.fontconfig.defaultFonts.sansSerif ++ config.fonts.fontconfig.defaultFonts.emoji;
            size = 0.8 * config.theme.fonts.size.ui;
          };

          keybindings = let
            bctl = "${pkgs.brightnessctl}/bin/brightnessctl";
            pamixer = "${pkgs.pamixer}/bin/pamixer";
            toWob = "> $XDG_RUNTIME_DIR/wob.sock";

            customKeybindings =
              {
                "${modifier}+v" = "split toggle";
                "${modifier}+Shift+p" = "bash -c \"${screenshot}/bin/screenshot\"";
                "--locked XF86MonBrightnessDown" = "exec ${bctl} set 5%- | sed -En 's/.*Current brightness: [0-9]+ \\(([0-9]+)%\\).*/\\1/p' ${toWob}";
                "--locked XF86MonBrightnessUp" = "exec ${bctl} set 5%+ | sed -En 's/.*Current brightness: [0-9]+ \\(([0-9]+)%\\).*/\\1/p' ${toWob}";
                "--locked XF86AudioMute" = "exec ${pamixer} -t";
                "--locked XF86AudioLowerVolume" = "exec ${pamixer} -d 5 && ${pamixer} --get-volume ${toWob}";
                "--locked XF86AudioRaiseVolume" = "exec ${pamixer} -i 5 && ${pamixer} --get-volume ${toWob}";
                "--locked XF86AudioMicMute" = "exec ${pamixer} -t --default-source";
              }
              // cfg.config.keybindings;
          in
            mkOptionDefault customKeybindings;

          terminal = config.user.terminalCmd;

          startup = let
            wobSock = "$XDG_RUNTIME_DIR/wob.sock";
          in
            cfg.config.startup
            ++ [
              {command = "rm -f ${wobSock} && mkfifo ${wobSock} && tail -f ${wobSock} | ${pkgs.wob}/bin/wob";}
              {
                always = true;
                command = "gsettings set org.gnome.desktop.interface gtk-theme '${gtk.theme.name}'";
              }
              {
                always = true;
                command = "gsettings set org.gnome.desktop.interface icon-theme '${gtk.iconTheme.name}'";
              }
              {
                always = true;
                command = "gsettings set org.gnome.desktop.interface cursor-theme '${gtk.cursorTheme.name}'";
              }
              {
                always = true;
                command = "gsettings set org.gnome.desktop.interface font-name '${gtk.font.name}'";
              }
            ];

          window.hideEdgeBorders = "smart";
          workspaceAutoBackAndForth = true;
        };

      wrapperFeatures.gtk = true;
    };
  };
}
