{
  config,
  lib,
  options,
  ...
}: let
  inherit (lib) mkEnableOption mkAliasDefinitions;
in {
  options.modules.services.clight.enable = mkEnableOption "Enables Clight brightness control service.";

  config.services.clight.enable = mkAliasDefinitions options.modules.services.clight.enable;
}
