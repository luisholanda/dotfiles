{
  config,
  pkgs,
  ...
}: {
  modules = {
    editors.neovim.enable = true;

    programs = {
      brave.enable = true;
      fish.enable = true;

      git = {
        enable = true;
        emailAccount = "personalProtonmail";
        addons.delta.enable = true;
      };

      gpg.enable = true;
      kitty.enable = true;
      ssh.enable = true;
    };
  };

  dotfiles.dir = /Users/lholanda/dotfiles;

  user = {
    name = "lholanda";
    description = "Luis Holanda";
    passwordFile = "${config.dotfiles.dir}/hosts/hephaestus/passfile";

    home.extraConfig.stylix.targets.vesktop.enable = true;

    accounts.email.accounts = {
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
      vesktop
      logseq
    ];
  };

  system.stateVersion = 5;
}
