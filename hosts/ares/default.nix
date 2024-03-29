{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.my) wrapProgram;
in {
  imports = [./hardware.nix];

  host.hardware.isIntel = true;
  host.hardware.gpu.isAMD = true;

  modules = {
    editors = {
      neovim.enable = true;
      helix.enable = true;
    };

    games.steam.enable = true;

    services = {
      dnscrypt-proxy2.enable = true;
      docker.enable = true;

      hyprland.enable = true;

      pipewire.enable = true;
    };

    programs = {
      brave.enable = true;
      fish.enable = true;

      git = {
        enable = true;
        emailAccount = "personalGmail";
        ssh.always = false;
        addons = {
          delta.enable = true;
        };
      };

      gpg.enable = true;
      kitty.enable = true;
      ssh.enable = true;
    };
  };

  services.resolved.enable =
    true;

  dotfiles.dir =
    /home/luiscm/dotfiles;

  user = {
    name = "luiscm";
    description = "Luis Holanda";
    # TODO: move these groups to their respective modules.
    groups = ["wheel" "networking" "video" "adbusers" "docker"];
    passwordFile = "${config.dotfiles.dir}/hosts/plutus/passfile";

    # Run Bazel sandbox inside a tempfs.
    home.file.".bazelrc".text = "build --sandbox_base=/dev/shm/";

    home.projectDirs = [
      "~/Projects"
    ];

    accounts.email.accounts = {
      personalGmail = rec {
        primary = true;
        flavor = "gmail.com";
        address = "luiscmholanda@gmail.com";
        realName = "Luis C. M. Holanda";
        userName = address;
        passwordCommand = "${pkgs.pass}/bin/pass show git-send-mail-gmail";

        gpg = {
          key = "DA2223669494475C";
          signByDefault = true;
          encryptByDefault = true;
        };
      };
    };

    packages = with pkgs; [
      bemenu
      discord
      nomacs
      pcmanfm
      zathura
      jetbrains.rust-rover
      (wrapProgram slack {
        appendFlags = [
          "--enable-zero-copy"
          "--use-angle=opengl"
          "--ignore-gpu-blocklist"
          "--ozone-platform=wayland"
        ];
      })
      (wrapProgram logseq {
        prefix.LD_LIBRARY_PATH = "${pkgs.libGL}/lib";
      })
      #lutris
    ];
  };

  theme.wallpaper =
    config.dotfiles.dir + "/wallpapers/bottle-miku.png";
  theme.polarity = "dark";
  theme.fonts = {
    serif = {
      package = pkgs.noto-fonts;
      name = "Noto Serif";
    };
    sansSerif = {
      package = pkgs.noto-fonts;
      name = "Noto Sans";
    };
    emoji = {
      package = pkgs.noto-fonts-emoji;
      name = "Noto Color Emoji";
    };
    monospace = {
      package = pkgs.pragmasevka;
      name = "Pragmasevka Nerd Font";
    };
    sizes.desktop = 12;
    sizes.terminal = 11;
  };

  documentation.man = {
    enable = true;
    generateCaches = true;
  };
}
