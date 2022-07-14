{ config, lib, pkgs, ... }: let
  inherit (lib) mkIf;

  theme = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/dracula/fish/d00be76c79486334efa90ed1831d8bc8087acd54/conf.d/dracula.fish";
    sha256 = "sha256:0dxfwvq9g371dq6bgj4m090wq09wf4dn8msy8mcvc1cdx6mfk3sn";
  };
in {
  config = mkIf config.theme.dracula.active {
    user.home.programs.fish.interactiveShellInit = builtins.readFile theme;
  };
}
