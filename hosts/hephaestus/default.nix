{
  config,
  pkgs,
  ...
}: {
  modules = {
    editors.neovim.enable = true;

    programs = {
      fish.enable = true;

      git = {
        enable = true;
        emailAccount = "personalProtonmail";
        addons.delta.enable = true;
        ssh.always = false;
      };

      gpg.enable = true;
      ssh.enable = true;
    };
  };

  dotfiles.dir = /Users/lholanda/dotfiles;

  user = {
    name = "lholanda";
    description = "Luis Holanda";

    home.extraConfig.stylix.targets.vesktop.enable = true;

    accounts.email.accounts = {
      personalProtonmail = rec {
        primary = true;
        flavor = "protonmail.com";
        address = "luiscmholanda@pm.me";
        realName = "Luis Holanda";
        userName = address;

        gpg = {
          key = "2BD82F194D71A437";
          signByDefault = true;
          encryptByDefault = true;
        };
      };
    };

    packages = with pkgs; [darwin-rebuild gh graphite-cli];

    home.extraConfig.home.stateVersion = "24.05";
    home.extraConfig.stylix.targets.fish.enable = false;
    home.file.".gnupg/gpg-agent.conf".text = ''
      pinentry-program ${pkgs.pinentry_mac}/bin/pinentry-mac
    '';
  };

  stylix.image = config.dotfiles.dir + "/wallpapers/youkai-color.png";
  stylix.fonts.sizes.terminal = 13;
  stylix.fonts.monospace = {
    package = pkgs.monaspace;
    name = "Monaspace Neon Var";
  };
  stylix.polarity = "dark";

  networking.knownNetworkServices = ["Wi-Fi"];
  system.stateVersion = 5;
  system.primaryUser = "lholanda";

  homebrew = {
    enable = true;
    caskArgs = {
      appdir = "/Applications/Brew Apps";
      require_sha = true;
    };
    onActivation.cleanup = "zap";
    brews = ["bazelisk" "pinentry"];
    casks = [
      "brave-browser"
      "datagrip"
      "ghostty"
      "obsidian"
      "raycast"
      "yaak"
      "zed"
    ];
  };

  nix-homebrew = {
    enable = true;
    user = config.user.name;
  };
}
