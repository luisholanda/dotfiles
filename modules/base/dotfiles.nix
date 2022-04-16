{ config, options, lib, ... }:
let
  inherit (lib.my) mkPathOpt mkPathWithDefaultOpt;

  dir = config.dotfiles.dir;
in
{
  options.dotfiles = {
    dir = mkPathOpt "Path to the dotfiles directory.";
    binDir = mkPathWithDefaultOpt (dir + "/bin") "Path to the dotfiles binary directory.";
    configDir = mkPathWithDefaultOpt (dir + "/config") "Path to the dotfiles configuration directory.";
  };
}
