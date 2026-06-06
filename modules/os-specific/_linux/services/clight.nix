{
  lib,
  config,
  ...
}: let
  inherit (lib) mkEnableOption;
in {
  options.modules.services.clight.enable = mkEnableOption "Enables Clight brightness control service.";

  config.services.clight.enable = config.modules.services.clight.enable;
}
