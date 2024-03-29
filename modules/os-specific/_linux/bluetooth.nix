{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkOption mkDefault types optional;
  inherit (lib.my) mkEnableOpt mkPkgOpt;

  cfg = config.modules.hardware.bluetooth;
in {
  options.modules.hardware.bluetooth = {
    enable = mkEnableOpt "Enable bluetooth hardware and software support";

    firmware = mkPkgOpt null "bluetooth firmware";
    kernelModule = mkOption {
      type = types.nullOr types.str;
      description = "Kernel module representing the bluetooth firmware";
      default = null;
    };
  };

  config = mkIf cfg.enable {
    boot.extraModulePackages = optional (cfg.firmware != null) cfg.firmware;
    boot.kernelModules = optional (cfg.kernelModule != null) cfg.kernelModule;

    hardware.bluetooth.enable = true;
    hardware.bluetooth.settings.General = mkDefault {
      AutoConnect = "true";
      Enable = "Source,Sink,Media,Socket";
      FastConnectable = "true";
      MultiProfile = "multiple";
    };

    hardware.pulseaudio.extraModules = [pkgs.pulseaudio-modules-bt];
    hardware.pulseaudio.extraConfig = ''
      load-module module-switch-on-connect

      unload module-bluetooth-policy
      load-module module-bluetooth-policy auto_switch=2

      unload module-bluetooth-discover
      load-module module-bluetooth-discover headset=native
    '';

    services.blueman.enable = true;

    systemd.user.services.mpris-proxy = {
      description = "MPRIS proxy";
      after = ["network.target" "sound.target"];
      wantedBy = ["default.target"];
      serviceConfig = {
        ExecStart = "${pkgs.bluez}/bin/mpris-proxy";
        RestartSec = 5;
        Restart = "always";
      };
    };
  };
}
