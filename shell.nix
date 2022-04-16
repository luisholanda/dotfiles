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
    };

    devshell.startup = {
      enable-pre-commit.text = pre-commit-check.shellHook;
    };
  }
