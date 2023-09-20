{
  config,
  lib,
  options,
  pkgs,
  ...
}: let
  inherit (lib) types mkAliasDefinitions mkOption splitString;
  inherit (lib.my) mkAttrsOpt mkPathOpt mkPkgOpt;

  cfg = config.user;
in {
  options.user = with types; {
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

    passwordFile = mkPathOpt ''
      The full path to a file that contains the user's password. The password
      file is read on each system activation. The file should contain exactly
      one line which should be the password in an encrypted form that is suitable
      for the <literal>chpasswd -e</literal> command.
    '';

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

    terminalCmd = mkOption {
      type = types.str;
      description = "Command to start the user terminal.";
      default = "";
    };

    sessionCmd = mkOption {
      type = types.str;
      description = "Command to start the user session.";
      default = "";
    };

    sessionVariables = mkOption {
      type = types.attrs;
      description = "Environment variables to always set at login";
      default = {};
    };

    shell = mkPkgOpt pkgs.shadow "User shell. Defaults to bash";

    shellAliases = mkOption {
      type = with types; attrsOf str;
      default = {};
      description = "Aliases to add to the user shell.";
    };

    home = {
      sessionPath = mkOption {
        type = listOf str;
        default = [];
        description = "Paths to be added to the session PATH.";
      };

      file = mkAttrsOpt "Files to be added to the home directory.";

      programs = mkAttrsOpt "Programs configurable via home-manager";
      services = mkAttrsOpt "Services configurable via home-manager";

      projectDirs = mkOption {
        type = listOf str;
        default = [];
        description = "Folders where projects are stored.";
      };

      extraConfig = mkAttrsOpt "Extra configuration for home-manager.";

      dir = mkOption {
        type = str;
        default = "/home/${cfg.name}";
        description = "Home directory for the user.";
      };
    };

    xdg = {
      configFile = mkAttrsOpt "Files to be added to $XDG_CONFIG_HOME";
      dataFile = mkAttrsOpt "Files to be added to $XDG_DATA_HOME";

      configDir = mkOption {
        type = str;
        default = "${cfg.home.dir}/.config";
        description = "Configuration directory for the user.";
      };
    };
  };

  config = {
    users.mutableUsers = false;
    users.users.${cfg.name} = {
      inherit (cfg) description shell packages;

      isNormalUser = true;
      home = cfg.home.dir;
      extraGroups = cfg.groups;
      hashedPassword = builtins.head (splitString "\n" (builtins.readFile cfg.passwordFile));
    };

    environment.shells = [cfg.shell];

    user.packages = with pkgs; [xdg_utils httpie jq];

    home-manager = {
      # Install user packages in /etc/profiles instead. Necessary for
      # nixos-rebuild build-vm to work.
      useGlobalPkgs = true;
      useUserPackages = true;

      users.${cfg.name} = let
        cleanExtraConfig = builtins.removeAttrs cfg.home.extraConfig ["programs" "services"];
      in
        cleanExtraConfig
        // {
          home.sessionVariables = cfg.sessionVariables;
          # Necessary for home-manager to work with flakes, otherwise it will
          # look for a nixpkgs channel.
          home.stateVersion = config.system.stateVersion;
          home.file = cfg.home.file;

          programs = mkAliasDefinitions options.user.home.programs;
          services = mkAliasDefinitions options.user.home.services;

          xdg.configFile = cfg.xdg.configFile;
          xdg.dataFile = cfg.xdg.dataFile;
        };
    };

    nix.settings.trusted-users = ["root" cfg.name];
    nix.settings.allowed-users = ["root" cfg.name];
  };
}
