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

      run-vm = {
        help = "run the vm for the current host, or the one specified by HOSTNAME";
        command = "make vm";
      };

      apply-config = {
        help = "apply the configuration of the current host";
        command = "TMPDIR=/nix/tmp nixos-rebuild switch --flake path:.#$(uname -n) --impure --show-trace";
      };
    };

    devshell.startup = {
      enable-pre-commit.text = pre-commit-check.shellHook;
    };

    devshell.packages = with pkgs; [gnumake];
  }
