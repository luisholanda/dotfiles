{ config, options, lib, ... }:
let
  inherit (lib.my) mkPathOpt mkPathWithDefaultOpt;
in
{
  options.dotfiles = {
    dir = mkPathOpt "Path to the dotfiles directory.";
    binDir = mkPathWithDefaultOpt "${config.dotfiles.dir}/bin" "Path to the dotfiles binary directory.";
    configDir = mkPathWithDefaultOpt "${config.dotfiles.dir}/config" "Path to the dotfiles configuration directory.";
  };
}
