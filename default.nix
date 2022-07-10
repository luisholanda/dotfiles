{
  inputs,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkDefault mkIf;
in {
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  system.configurationRevision = with inputs; mkIf (self ? rev) self.rev;
  system.stateVersion = mkDefault "22.05";

  ## Reasonable global defaults
  # This is here to appease `nix flake check` for generic hosts with no
  # hardware-configuration.nix or fileSystem config.
  fileSystems."/".device = mkDefault "/dev/disk/by-label/nixos";

  # only add stuff here that will be used by _all_ hosts.
  environment.systemPackages = with pkgs; [
    cacert
    cached-nix-shell
    coreutils
    curl
    jq
    wget
    unzip
  ];
}
