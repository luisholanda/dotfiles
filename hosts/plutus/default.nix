{ config, lib, ... }:
{
  imports = [ ./hardware.nix ];

  modules = {
    services = {
      sway.enable = true;
      mako.enable = true;
      waybar.enable = true;
    };
  };

  dotfiles = {
    dir = /home/luiscm/Sources/new-dotfiles;
  };

  user = {
    name = "luiscm";
    description = "Luis C. M. Holanda";
    # TODO: move these groups to their respective modules.
    groups = [ "wheel" "networking" "wideo" "adbusers" "docker" ];
    passwordFile = "${config.dotfiles.dir}/hosts/plutus/passfile";
  };

  documentation = {
    dev.enable = true;
    doc.enable = true;
    man.generateCaches = true;
  };
}
