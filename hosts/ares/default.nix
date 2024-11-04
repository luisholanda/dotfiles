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
  host.hardware.gpu.isNVIDIA = true;

  modules = {
    editors.neovim.enable = true;
    games.steam.enable = true;

    services = {
      docker.enable = true;

      hyprland.enable = true;

      pipewire.enable = true;
    };

    programs = {
      brave.enable = true;
      fish.enable = true;

      git = {
        enable = true;
        emailAccount = "personalProtonmail";
        ssh.always = true;
        ssh.keys."gitlab.com" = "~/.ssh/gitlab_key";
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
    passwordFile = "${config.dotfiles.dir}/hosts/ares/passfile";

    # Run Bazel sandbox inside a tempfs.
    home.file.".bazelrc".text = "build --sandbox_base=/dev/shm/";

    home.projectDirs = [
      "~/Projects"
    ];

    home.extraConfig.stylix.targets.vesktop.enable = true;

    accounts.email.accounts = {
      personalGmail = rec {
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
      personalProtonmail = rec {
        primary = true;
        flavor = "protonmail.com";
        address = "luiscmholanda@protonmail.com";
        realName = "Luis Holanda";
        userName = address;

        gpg = {
          key = "27D88FA704EDF786";
          signByDefault = true;
          encryptByDefault = true;
        };
      };
    };

    packages = with pkgs; [
      bemenu
      vesktop
      nomacs
      protonmail-desktop
      zathura
      (wrapProgram logseq {
        prefix.LD_LIBRARY_PATH = "${pkgs.libGL}/lib";
      })
      (wrapOBS {
        plugins = with obs-studio-plugins; [wlrobs input-overlay obs-pipewire-audio-capture];
      })
    ];
  };

  systemd.packages = with pkgs; [pritunl-client];

  stylix.cursor.package = pkgs.google-cursor;
  stylix.cursor.name = "GoogleDot-White";
  stylix.cursor.size = 24;

  stylix.image =
    config.dotfiles.dir + "/wallpapers/youkai-grey.jpg";
  stylix.polarity = "dark";
  stylix.fonts = {
    monospace = {
      package = pkgs.unstable.nerdfonts.override {
        fonts = ["Monaspace"];
      };
      name = "MonaspiceNe Nerd Font Mono";
    };
    sansSerif = {
      package = pkgs.atkinson-hyperlegible;
      name = "Atkinson Hyperlegible";
    };
    sizes.terminal = 10;
  };
  user.home.programs.kitty.extraConfig = let
    sss =
      builtins.concatStringsSep " "
      (map (i: "+ss0${toString i}") (lib.range 1 9));
    styles = [
      "Bold"
      "BoldItalic"
      "Italic"
      "Light"
      "LightItalic"
      "Medium"
      "MediumItalic"
      "Regular"
    ];
    font-name = "MonaspiceNeNFM";
    extra-features = "+calt +liga";
  in
    builtins.concatStringsSep "\n" (builtins.map (s: "font_features ${font-name}-${s} ${extra-features} ${sss}") styles);

  documentation.man = {
    enable = true;
    generateCaches = true;
  };
}
