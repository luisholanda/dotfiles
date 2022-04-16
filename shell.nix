{
  pkgs,
  pre-commit-check,
}: let
  inherit (pkgs.lib.my) attrsToList;
  attrsToCommand = attrs:
    map ({
      name,
      value,
    }:
      value // {inherit name;}) (attrsToList attrs);
in
  pkgs.devshell.mkShell {
    name = "dotfiles";

    commands = attrsToCommand {
      check = {
        help = "run pre-commit checks";
        command = "pre-commit run -a";
      };

      flake-check = {
        help = "run flake checks";
        command = "make check";
      };

      mk = {
        help = "an easier alias for GNU make";
        command = "make";
        package = pkgs.gnumake;
      };
    };

    devshell.startup = {
      enable-pre-commit.text = pre-commit-check.shellHook;
    };
  }
