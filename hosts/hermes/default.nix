{
  config,
  pkgs,
  ...
}: {
  imports = [./hardware.nix];

  host.hardware.isAMD = true;
  host.hardware.isLaptop = true;

  theme.wallpaper = ../../wallpapers/oshinoko-eyes.jpg;

  modules = {
    editors = {
      neovim.enable = true;
    };

    hardware.bluetooth.enable = true;

    services = {
      audio.spotify.enable = true;
      dnscrypt-proxy2.enable = true;
      docker.enable = true;
      gammastep.enable = true;

      pipewire.enable = true;

      hyprland.enable = true;

      clight.enable = true;
    };

    programs = {
      alacritty.enable = false;
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
      mpv.enable = true;
      ssh.enable = true;
    };
  };

  services.resolved.enable = true;

  dotfiles.dir = /home/luiscm/.dotfiles;

  user = {
    name = "luiscm";
    description = "Luis Holanda";
    # TODO: move these groups to their respective modules.
    groups = ["wheel" "networking" "video" "adbusers" "docker" "input"];
    passwordFile = "${config.dotfiles.dir}/hosts/hermes/passfile";

    # Run Bazel sandbox inside a tempfs.
    home.file.".bazelrc".text = "build --sandbox_base=/dev/shm/";

    home.projectDirs = ["~/Sources"];

    accounts.email.accounts = {
      personalGmail = rec {
        primary = true;
        flavor = "gmail.com";
        address = "luiscmholanda@gmail.com";
        realName = "Luis Holanda";
        userName = address;
        passwordCommand = "${pkgs.pass} show git-send-mail-gmail";

        gpg = {
          key = "DA2223669494475C";
          signByDefault = true;
          encryptByDefault = true;
        };
      };
    };

    home.extraConfig.services.gnome-keyring.enable = true;
    packages = with pkgs; [
      nomacs
      pcmanfm
      zathura
      slack
      libsecret
      ripgrep
      fd
      thunderbird
    ];
  };

  documentation = {
    nixos.includeAllModules = false;
    doc.enable = false;
    man.generateCaches = false;
    man.enable = false;
  };

  programs.seahorse.enable = true;
  services.gnome.at-spi2-core.enable = true;
  security.pam.services.gnome_keyring.text = ''
    auth     optional    ${pkgs.gnome.gnome-keyring}/lib/security/pam_gnome_keyring.so
    session  optional    ${pkgs.gnome.gnome-keyring}/lib/security/pam_gnome_keyring.so auto_start

    password  optional    ${pkgs.gnome.gnome-keyring}/lib/security/pam_gnome_keyring.so
  '';

  networking.wireless.iwd = {
    enable = true;
    settings = {
      General = {
        EnableNetworkConfiguration = true;
        AddressRandomization = "network";
      };
      Network.EnableIPv6 = true;
    };
  };

  system.userActivationScripts = {
    rfkillUnblockWlan = {
      text = ''
        rfkill unblock wlan
      '';
      deps = [];
    };
  };

  services.xserver.enable = true;
  #services.xserver.displayManager.gdm.enable = true;

  # / is too small to build things in /tmp
  nix.envVars.TMPDIR = "/nix/tmp";
}
