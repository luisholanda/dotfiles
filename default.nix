{ inputs, config, lib, pkgs, ... }:
let
  inherit (builtins) map;
  inherit (lib) filterAttrs mapAttrs mapAttrsToList mkDefault mkIf;
  inherit (lib.my)  mapModulesRec';
  inherit (pkgs.stdenv) isDarwin;
in {
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  system.configurationRevision = with inputs; mkIf (self ? rev) self.rev;
  system.stateVersion = "21.11";

  ## Reasonable global defaults
  # This is here to appease `nix flake check` for generic hosts with no
  # hardware-configuration.nix or fileSystem config.
  fileSystems."/".device = mkDefault "/dev/disk/by-label/nixos";

  environment.systemPackages = with pkgs; [
    cached-nix-shell
    coreutils
    vim
    git
    wget
    gnumake
    unzip
  ];
}
