{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (config.host.hardware) isLaptop;
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

    powerManagement.powertop.enable = true;
  };
}
