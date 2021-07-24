{ config, options, lib, ... }:
let
  inherit (lib.my) mkPathOpt mkPathWithDefaultOpt;
in {
  options.dotfiles = {
    dir = mkPathOpt "Path to the dotfiles directory.";
    binDir = mkPathWithDefaultOpt  "${config.dotfiles.dir}/bin";
    configDir = mkPathWithDefaultOpt "${config.dotfiles.dir}/config";
  };
}
