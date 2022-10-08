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
        command = "nix flake check path:. --impure";
      };

      run-vm = {
        help = "run the vm for the current host, or the one specified by HOSTNAME";
        command = "make vm";
      };

      apply-config = {
        help = "apply the configuration of the current host";
        command = ''
          nixos-rebuild switch --flake path:.#$(uname -n) --impure -j $(expr 3 \* $(nproc) / 4) $@
        '';
      };
    };

    devshell.startup = {
      enable-pre-commit.text = pre-commit-check.shellHook;
    };

    devshell.packages = with pkgs; [gnumake];
  }
