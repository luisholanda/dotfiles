{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption;
in {
  options.modules.services.docker = {
    enable = mkEnableOption "docker";
    enableOnBoot = mkEnableOption "docker on boot";
  };

  config = {
    virtualisation.docker = {
      inherit (config.modules.services.docker) enable enableOnBoot;

      autoPrune.enable = true;

      daemon.settings = {
        dns = ["127.0.0.1"];
      };
    };
  };
}
