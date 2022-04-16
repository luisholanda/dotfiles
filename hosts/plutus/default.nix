{ config, lib, ... }:
let
  inherit (lib.my) mkColor;

in {
  imports = [ ./hardware.nix ];

  modules = {
    editors.neovim.enable = true;

    services = {
      sway.enable = true;
      mako.enable = true;
      waybar.enable = true;
    };

    programs = {
      alacritty.enable = false;
      kitty.enable = true;
      brave.enable = true;
      fish.enable = true;
      git = {
        enable = true;
        emailAccount = "personalGmail";
        addons = {
          delta.enable = true;
          stgit.enable = true;
        };
      };
      gpg.enable = true;
      mpv.enable = true;
      ssh.enable = true;
    };
  };

  theme.fonts.size.text = 16;
  theme.fonts.size.ui = 16;

  theme.colors = rec {
    background = mkColor "#2B2D3A";
    foreground = mkColor "#E1E3E4";
    normal = {
      black = mkColor "#181A1C";
      red = mkColor "#FB617E";
      green = mkColor "#9ED06C";
      yellow = mkColor "#EDC763";
      blue = mkColor "#6DCAE8";
      magenta = mkColor "#BB97EE";
      cyan = mkColor "#F89860";
      white = mkColor "#E1E3E4";
    };

    bright = {
      black = mkColor "#181A1C";
      red = mkColor "#FB617E";
      green = mkColor "#9ED06C";
      yellow = mkColor "#EDC763";
      blue = mkColor "#6DCAE8";
      magenta = mkColor "#BB97EE";
      cyan = mkColor "#F89860";
      white = mkColor "#E1E3E4";
    };
  };

  dotfiles = {
    dir = /home/luiscm/Sources/new-dotfiles;
  };

  user = {
    name = "luiscm";
    description = "Luis C. M. de Holanda";
    # TODO: move these groups to their respective modules.
    groups = [ "wheel" "networking" "wideo" "adbusers" "docker" ];
    passwordFile = "${config.dotfiles.dir}/hosts/plutus/passfile";

    accounts.email.accounts = {
      personalGmail = {
        primary = true;
        flavor = "gmail.com";
        address = "luiscmholanda@gmail.com";
        realName = "Luis C. M. Holanda";

        gpg = {
          key = "DA2223669494475C";
          signByDefault = true;
          encryptByDefault = true;
        };
      };
    };
  };

  documentation = {
    dev.enable = true;
    doc.enable = true;
    man.generateCaches = true;
  };
}
