{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  inherit (config.lib.stylix) colors;
  inherit (config.stylix) cursor fonts;

  active = colors.base0A;
  inactive = colors.base03;

  screenshot = pkgs.writeScriptBin "screenshot" ''
    #!${pkgs.bash}/bin/bash
    filename="screenshot-$(date +%F-%T)"
    ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" ~/Screenshots/$filename.png
  '';

  startUserService = service: "exec-once = systemctl start --user ${service}";
in {
  options.modules.services.hyprland.enable = mkEnableOption "hyprland";

  config = mkIf config.modules.services.hyprland.enable {
    environment.systemPackages = with pkgs; [
      bemenu
      screenshot
      wl-clipboard
    ];

    xdg.portal = {
      extraPortals = [pkgs.unstable.xdg-desktop-portal-hyprland];
      configPackages = [pkgs.unstable.hyprland];
    };

    user.home = {
      extraConfig.wayland.windowManager.hyprland = {
        package = pkgs.unstable.hyprland;
        enable = true;
        xwayland.enable = true;
        systemd.enableXdgAutostart = true;
        configType = "hyprlang";
      };

      programs.ashell = {
        enable = true;
        package = pkgs.unstable.ashell;
        systemd.enable = true;
        settings = {
          enable_esc_key = true;
          outputs = "All";

          modules = {
            left = [
              "Workspaces"
              "MediaPlayer"
            ];
            center = ["WindowTitle"];
            right = [
              "Tray"
              [
                "SystemInfo"
              ]
              "Tempo"
              [
                "Privacy"
                "Settings"
              ]
            ];
          };

          system_info = {
            indicators = [
              "Cpu"
              "Memory"
              "MemorySwap"
            ];
          };

          window_title = {
            mode = "Title";
          };

          settings = {
            indicators = [
              "Audio"
              "Network"
            ];
            lock_cmd = "pidof hyprlock || hyprlock &";
            audio_indicator_format = "IconAndPercentage";
            audio_sinks_more_cmd = "${pkgs.pavucontrol}/bin/pavucontrol -t 3";
            audio_sources_more_cmd = "${pkgs.pavucontrol}/bin/pavucontrol -t 4";
            remove_airplane_btn = true;
            remove_idle_btn = true;
          };
        };
      };

      programs.hyprlock = {
        enable = true;
        settings = {
          general = {
            hide_cursor = true;
          };

          label = [
            {
              position = "0, 0";
              halign = "center";
              valign = "center";
              text = "cmd[update:60000] $(date) ｜ $TIME12";
            }
          ];
        };
      };

      services.hyprpaper.settings = {
        splash = false;

        wallpapers = [
          {
            path = config.stylix.image;
          }
        ];
      };

      services.hypridle.enable = true;
      services.hypridle.settings = {
        general = {
          after_sleep_cmd = "hyprctl dispatch dpms on";
          lock_cmd = "pidof hyprlock || hyprlock";
          before_sleep_cmd = "loginctl lock-session";
        };

        listeners = [
          {
            timeout = 60;
            on-timeout = "loginctl lock-session";
          }
          {
            timeout = 150;
            on-timeout = "brightnessctl -s set 10";
            on-resume = "brightnessctl -r";
          }
          {
            timeout = 300;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on && brightnessctl -r";
          }
          {
            timeout = 3600;
            on-timeout = "systemctl suspend";
          }
        ];
      };

      services.hyprpolkitagent.enable = false;
    };

    user.sessionVariables.NIXOS_OZONE_WL = 1;
    user.xdg.configFile."hypr/hyprland.conf".text = ''
      source = ${config.dotfiles.configDir}/hyprland.conf

      debug {
        disable_logs = false
      }

      exec-once = ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd --all
      exec-once = systemctl --user import-environment QT_QPA_PLATFORMTHEME

      exec-once = gsettings set org.gnome.desktop.interface cursor-theme '${cursor.name}'
      exec-once = gsettings set org.gnome.desktop.interface font-theme '${fonts.sansSerif.name}'

      ${startUserService "xdg-desktop-portal-hyprland"}

      general {
        col.active_border = rgb(${active})
        col.inactive_border = rgb(${inactive})
      }
    '';

    security.pam.services.hyprlock = {};
  };
}
