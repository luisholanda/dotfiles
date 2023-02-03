{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (pkgs.stdenv) isLinux;
in {
  config.services.udisks2.enable = mkIf isLinux true;
}
