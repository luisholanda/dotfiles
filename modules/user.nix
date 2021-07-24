{ config, lib, options, pkgs, ... }:
let
  inherit (lib) types mkAliasDefinitions mkOption;

  cfg = config.user;
in
{
  options.user = mkOption {
    description = "Configuration of the main host's user.";
    type = with types; submodule {
      name = mkOption {
        type = str;
        description = "The name of the user account.";
      };

      description = mkOption {
        type = str;
        default = "";
        example = "Alice Q. User";
        description = ''
          A short description of the user account, typically the
          user's full name. This is actually the "GECOS" or "comment"
          field in <filename>/etc/passwd</filename>
        '';
      };

      groups = mkOption {
        type = listOf str;
        default = [];
        description = "The user's groups.";
      };

      passwordFile = mkOption {
        type = str;
        description = ''
          The full path to a file that contains the user's password. The password
          file is read on each system activation. The file should contain exactly
          one line which should be the password in an encrypted form that is suitable
          for the <literal>chpasswd -e</literal> command.
        '';
      };

      packages = mkOption {
        type = listOf package;
        default = [];
        example = lib.literalExample "[ pkgs.firefox pkgs.thunderbird ]";
        description = ''
          The set of packages that should be made available to the user.
          This is in contrast to <option>environment.systemPackages</option>,
          which adds packages to all users.
        '';
      };

      sessionVariables = mkOption {
        type = types.attrs;
        description = "Environment variables to always set at login";
        default = {};
      };

      shellAliases = mkOption {
        type = with types; attrsOf str;
        default = {};
        description = "Aliases to add to the user shell.";
      };

      home = mkOption {
        description = "The Home-Manager configuration for this user.";
        type = submodule {
          sessionPath = mkOption {
            type = listOf str;
            default = [];
            description = "Paths to be added to the session PATH.";
          };

          file = mkOption {
            type = attrs;
            default = {};
            description = "Files to be added to the home directory.";
          };

          programs = {
            type = attrs;
            default = {};
            description = "Programs configurable via home-manager";
          };

          projectDirs = {
            type = listOf str;
            default = [];
            description = "Folders where projects are stored.";
          };

          extraConfig = {
            type = attrs;
            default = {};
            description = "Extra configuration for home-manageer.";
          };
        };
      };

      xdg = {
        configFile = {
          type = attrs;
          default = {};
          description = "Files to be added to $XDG_CONFIG_HOME";
        };

        dataFile = {
          type = attrs;
          default = {};
          description = "Files to be added to $XDG_DATA_HOME";
        };
      };
    };
  };

  config = {
    users.mutableUsers = false;
    users.users.${cfg.name} = {
      createHome = true;
      isNormalUser = true;
      home = "/home/${cfg.name}";

      description = cfg.description;
      extraGroups = cfg.groups;
      passwordFile = cfg.passwordFile;
      packages = cfg.packages;
    };

    home-manager = {
      # Install user packages in /etc/profiles instead. Necessary for
      # nixos-rebuild build-vm to work.
      useUserPackages = true;

      users.${cfg.name} = {
        home = {
          file = mkAliasDefinitions options.user.home.file;
          # Necessary for home-manager to work with flakes, otherwise it will
          # look for a nixpkgs channel.
          stateVersion = config.system.stateVersion;
          sessionVariables = cfg.sessionVariables;
        };

        programs = mkAliasDefinitions options.user.home.programs;

        xdg = {
          configFile = mkAliasDefinitions options.user.xdg.configFile;
          dataFile = mkAliasDefinitions options.user.xdg.dataFile;
        };
      } // cfg.home.extraConfig;
    };

    nix = let
      users = [ "root" cfg.name ];
    in
      {
        trustedUsers = users;
        allowedUsers = users;
      };
  };
}
