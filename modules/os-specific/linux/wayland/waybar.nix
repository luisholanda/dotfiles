{
  config,
  pkgs,
  ...
}: let
  inherit (config.modules.services) sway hyprland;

  isWaylandEnabled = sway.enable || hyprland.enable;
in {
  config = {
    user.home.extraConfig.stylix.targets.waybar = {
      enableCenterBackColors = true;
      enableLeftBackColors = true;
      enableRightBackColors = true;
    };

    user.home.programs.waybar.enable = isWaylandEnabled;
    user.home.programs.waybar.systemd.enable = isWaylandEnabled;
    user.home.programs.waybar.settings = {
      mainBar = {
        layer = "top";
        position = "top";
        output = ["DP-1"];
        ipc = sway.enable;
        modules-left = [
          "temperature"
          "cpu"
        ];
        modules-center = [
          "mpris"
        ];
        modules-right = [
          "wireplumber"
          "clock"
          "tray"
        ];

        clock = {
          format = "{:%H:%M} ";
          format-alt = "{:%A, %B %d, %Y (%R)} ";
          tooltip-format = "<tt>{calendar}</tt>";
          calendar = {
            mode = "month";
            on-scroll = 1;
            on-click-right = "mode";
            format = {
              days = "<span id='day'><b>{}</b></span>";
              weekdays = "<span id='weekday'><b>{}</b></span>";
              today = "<span id='today'><b>{}</b></span>";
            };
          };
          actions.on-click-right = "mode";
        };

        cpu = {
          format = "{icon0} {icon1} {icon2} {icon3} {icon4} {icon5}";
          format-icons = ["▁" "▂" "▃" "▄" "▅" "▆" "▇" "█"];
        };

        mpris = {
          format-playing = "{artist}, <b>{title}</b>";
          format-paused = "⏸ {artist}, <b>{title}</b>";
          format-stopped = "";
        };

        temperature = {
          format = "{temperatureC}°C ";
          critical-threshold = 85;
          termal-zone = "thermal_zone1";
        };

        wireplumber = {
          format = "{volume}% {icon}";
          format-muted = "";
          on-click = "${pkgs.helvum}/bin/helvum";
          format-icons = ["" "" ""];
        };
      };
    };
  };
}
