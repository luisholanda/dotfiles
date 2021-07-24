{ config, lib, pkgs, ... }:
let
  inherit (lib.my) mkEnableOpt;
in {
  options.modules.services.mako = {
    enable = mkEnableOpt "Enable mako notification daemon.";
  };
}
