{
  config,
  pkgs,
  ...
}: let
  inherit (config.modules.services) sway hyprland;

  isWaylandEnabled = sway.enable || hyprland.enable;

  colors = with config.lib.stylix.colors.withHashtag;
  with config.stylix.fonts; ''
    @define-color base00 ${base00}; @define-color base01 ${base01}; @define-color base02 ${base02}; @define-color base03 ${base03};
    @define-color base04 ${base04}; @define-color base05 ${base05}; @define-color base06 ${base06}; @define-color base07 ${base07};

    @define-color base08 ${base08}; @define-color base09 ${base09}; @define-color base0A ${base0A}; @define-color base0B ${base0B};
    @define-color base0C ${base0C}; @define-color base0D ${base0D}; @define-color base0E ${base0E}; @define-color base0F ${base0F};

    * {
        font-family: ${sansSerif.name};
        font-size: ${builtins.toString sizes.desktop}pt;
    }
  '';
in {
  config = {
    # Use our custom style.
    user.home.extraConfig.stylix.targets.waybar.enable = false;

    user.home.programs.waybar.enable = isWaylandEnabled;
    user.home.programs.waybar.systemd.enable = isWaylandEnabled;
    user.home.programs.waybar.style = colors + (builtins.readFile ./waybar.css);
    user.home.programs.waybar.settings = {
      mainBar = {
        layer = "top";
        position = "bottom";
        output = ["HDMI-A-1" "DP-1"];
        ipc = sway.enable;
        modules-left = [
          "temperature"
          "cpu"
          "memory"
        ];
        modules-center = [
          "mpris"
        ];
        modules-right = [
          "privacy"
          "wireplumber"
          "clock"
          "tray"
        ];

        clock = {
          format = "{:%H:%M}  ";
          format-alt = "{:%A, %B %d, %Y (%R)} ";
          tooltip-format = "<tt>{calendar}</tt>";
          calendar = {
            mode = "month";
            on-scroll = 1;
            on-click-right = "mode";
            format = {
              days = "<span><b>{}</b></span>";
              weekdays = "<span><b>{}</b></span>";
              today = "<span><b>{}</b></span>";
            };
          };
          actions.on-click-right = "mode";
        };

        cpu = {
          format = "{icon0} {icon1} {icon2} {icon3} {icon4} {icon5}";
          format-icons = ["▁" "▂" "▃" "▄" "▅" "▆" "▇" "█"];
        };

        memory = {
          interval = 30;
          format = "{percentage}% + {swapPercentage}%  ";
        };

        mpris = {
          format-playing = "{artist}, <b>{title}</b>";
          format-paused = "⏸ {artist}, <b>{title}</b>";
          format-stopped = "";
        };

        privacy = {
          icon-spacing = 4;
          icon-size = 18;
          transition-duration = 250;
          modules = let
            mod = type: {
              inherit type;
              tooptip = true;
              tooltip-icon-size = 24;
            };
          in
            builtins.map mod ["screenshare" "audio-in" "audio-out"];
        };

        temperature = {
          format = "{temperatureC}°C ";
          critical-threshold = 85;
          termal-zone = "thermal_zone1";
        };

        wireplumber = {
          format = "{volume}% {icon}";
          format-muted = "";
          on-click = "${pkgs.easyeffects}/bin/easyeffects";
          format-icons = ["" "" " "];
        };
      };
    };
  };
}
