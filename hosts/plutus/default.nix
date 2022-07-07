{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.my) mkColor;
in {
  imports = [./hardware.nix];

  host.hardware.isIntel = true;

  modules = {
    editors = {
      neovim.enable = true;
      emacs.doom.enable = true;

      # XX: should these be configured in some sort of per-language configuration?
      extraPackages = with pkgs; [
        nodePackages.bash-language-server
        nodePackages.pyright
        nodePackages.typescript-language-server
        nodePackages.vim-language-server
        nodePackages.vls
        rnix-lsp
        rust-analyzer
        sumneko-lua-language-server
        terraform-ls
        ripgrep
        fd
      ];
    };

    services = {
      audio.spotify.enable = true;
      dnscrypt-proxy2.enable = true;
      docker.enable = true;
      gammastep.enable = true;
      mako.enable = true;

      pipewire.enable = true;

      sway = {
        enable = true;

        config.output = {
          HDMI-A-1 = {
            position = "2560 -750";
            transform = "90";
          };

          HDMI-A-2 = {
            position = "0 0";
            mode = "2560x1080@74.991Hz";
          };
        };
      };

      waybar.enable = true;
    };

    programs = {
      alacritty.enable = false;
      brave.enable = true;
      fish.enable = true;

      firefox = {
        enable = true;
        extensions = with pkgs.firefox.extensions; [
          bitwarden
          multi-account-containers
          refined-github
          vim-vixen
          ublock-origin
        ];

        userChrome = ./firefox-userChrome.css;
        userContent = [./firefox-userContent.css];
      };

      git = {
        enable = true;
        emailAccount = "personalGmail";
        ssh.always = false;
        addons = {
          delta.enable = true;
          stgit.enable = true;
          stack.enable = true;
        };
      };

      gpg.enable = true;
      kitty.enable = true;
      mpv.enable = true;
      ssh.enable = true;
    };
  };

  services.resolved.enable = true;

  theme.fonts = {
    family = {
      monospace = "JetBrainsMono Nerd Font";
      serif = "Noto Serif";
      sansSerif = "Noto Sans";
    };

    nerdfonts = ["JetBrainsMono"];
    packages = with pkgs; [
      font-awesome
      lmodern
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
    ];

    size.text = 12.0;
    size.ui = 12.0;
  };

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
    groups = ["wheel" "networking" "wideo" "adbusers" "docker"];
    passwordFile = "${config.dotfiles.dir}/hosts/plutus/passfile";

    # Run Bazel sandbox inside a tempfs.
    home.file.".bazelrc".text = "build --sandbox_base=/dev/shm/";

    home.projectDirs = [
      "~/TerraMagna/repositories"
      "~/Projects"
      "~/Sources"
    ];

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

    home.extraConfig.gtk = {
      enable = true;
      font.name = config.theme.fonts.family.sansSerif;
      font.size = builtins.floor config.theme.fonts.size.ui;
      cursorTheme = {
        package = pkgs.quintom-cursor-theme;
        name = "Quintom_Ink";
        size = 16;
      };
      iconTheme.package = pkgs.gnome.adwaita-icon-theme;
      iconTheme.name = "Adwaita";
      theme = {
        name = "Yaru";
        package = pkgs.yaru-theme;
      };
    };
    home.extraConfig.qt = {
      enable = true;
      platformTheme = "gtk";
    };
    home.extraConfig.services.gnome-keyring.enable = true;

    packages = with pkgs; [
      nomacs
      pcmanfm
      texlab
      zathura
      slack
      notion-app-enhanced
      minecraft
      libsecret
    ];
  };

  documentation = {
    dev.enable = true;
    doc.enable = true;
    man.generateCaches = true;
  };

  virtualisation.virtualbox.host.enable = false;

  programs.dconf.enable = true;

  programs.seahorse.enable = true;
  services.gnome.at-spi2-core.enable = true;
  security.pam.services.gnome_keyring.text = ''
    auth     optional    ${pkgs.gnome.gnome-keyring}/lib/security/pam_gnome_keyring.so
    session  optional    ${pkgs.gnome.gnome-keyring}/lib/security/pam_gnome_keyring.so auto_start

    password  optional    ${pkgs.gnome.gnome-keyring}/lib/security/pam_gnome_keyring.so
  '';
}
