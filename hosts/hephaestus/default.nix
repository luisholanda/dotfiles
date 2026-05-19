{
  config,
  pkgs,
  ...
}: {
  modules = {
    editors.helix.enable = true;
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

    packages = with pkgs; [
      bun
      darwin-rebuild
      jujutsu
      lazyjj
      nodejs_24
      gh
      prek
      uv
    ];

    home.extraConfig.home.stateVersion = "24.05";
    home.extraConfig.stylix.targets.fish.enable = false;
    home.file.".gnupg/gpg-agent.conf".text = ''
      pinentry-program ${pkgs.pinentry_mac}/bin/pinentry-mac
    '';

    home.programs.ghostty.enable = true;
    home.programs.ghostty.package = null;

    home.programs.ssh.matchBlocks = {
      "coder.*" = {
        proxyCommand = ''/opt/homebrew/bin/coder --global-config "/Users/lholanda/Library/Application Support/coderv2" ssh --stdio --ssh-host-prefix coder. %h'';
        userKnownHostsFile = "/dev/null";
        extraOptions = {
          ConnectTimeout = "0";
          StrictHostKeyChecking = "no";
          LogLevel = "ERROR";
        };
      };
      "*.coder" = {
        match = ''host *.coder !exec "/opt/homebrew/bin/coder connect exists %h"'';
        proxyCommand = ''/opt/homebrew/bin/coder --global-config "/Users/lholanda/Library/Application Support/coderv2" ssh --stdio --ssh-host-prefix coder. %h'';
        userKnownHostsFile = "/dev/null";
        extraOptions = {
          ConnectTimeout = "0";
          StrictHostKeyChecking = "no";
          LogLevel = "ERROR";
        };
      };
    };
  };

  stylix.image = config.dotfiles.dir + "/wallpapers/youkai-color.png";
  stylix.fonts.sizes.terminal = 13;
  stylix.fonts.monospace = {
    package = pkgs.maple-mono.variable;
    name = "Maple Mono";
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
    brews = [
      "bazelisk"
      "coder"
      "go"
      "elan-init"
      "pinentry"
      "opencode"
    ];
    casks = [
      "brave-browser"
      "claude-code"
      "datagrip"
      "ghostty"
      "obsidian"
      "orbstack"
      "raycast"
      "twingate"
      "yaak"
      "zed"
    ];
  };

  nix-homebrew = {
    enable = true;
    user = config.user.name;
  };
}
