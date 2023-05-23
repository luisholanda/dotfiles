{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkMerge;
  inherit (config.host.hardware) isLaptop isIntel;

  haveRDWDeps = config.networking.networkmanager.enable;
in {
  config = mkIf isLaptop {
    services.logind = rec {
      lidSwitch = "suspend-then-hibernate";
      lidSwitchDocked = lidSwitch;
      lidSwitchExternalPower = "lock";
      extraConfig = ''
        IdleAction=lock
        IdleActionSec=5min
        HandlePowerKey=hibernate
        HandlePowerKeyLongPress=reboot
      '';
    };

    services.upower.enable = true;

    systemd.sleep.extraConfig = ''
      HibernateDelaySec=60min
    '';

    services.tlp.enable = true;
    services.tlp.settings = mkMerge [
      {
        DISK_IOSCHED = "bfq bfq";
        PLATFORM_PROFILE_ON_AC = "balanced";
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "schedutil";
        START_CHARGE_TRESH_BAT0 = 0;
        STOP_CHARGE_TRESH_BAT0 = 1;
      }
      (mkIf isIntel {
        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      })
      (mkIf haveRDWDeps {
        DEVICE_TO_DISABLE_ON_LAN_CONNECT = "wifi wwan";
        DEVICE_TO_DISABLE_ON_WIFI_CONNECT = "wwan";
        DEVICE_TO_DISABLE_ON_WWAN_CONNECT = "wifi";

        DEVICE_TO_ENABLE_ON_LAN_DISCONECT = "wifi wwan";
        DEVICE_TO_ENABLE_ON_WIFI_DISCONNECT = "wwan";
        DEVICE_TO_ENABLE_ON_WWAN_DISCONNECT = "wifi";
      })
    ];
  };
}
