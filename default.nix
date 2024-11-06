{
  inputs,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkDefault mkIf;
in {
  imports = [
    # renamed stuff on unstable.
    (lib.mkAliasOptionModule ["hardware" "graphics" "enable"] ["hardware" "opengl" "enable"])
    (lib.mkAliasOptionModule ["hardware" "graphics" "enable32Bit"] ["hardware" "opengl" "driSupport32Bit"])
    (lib.mkAliasOptionModule ["hardware" "graphics" "package"] ["hardware" "opengl" "package"])
    (lib.mkAliasOptionModule ["hardware" "graphics" "package32"] ["hardware" "opengl" "package32"])
    (lib.mkAliasOptionModule ["hardware" "graphics" "extraPackages"] ["hardware" "opengl" "extraPackages"])
    (lib.mkAliasOptionModule ["hardware" "graphics" "extraPackages32"] ["hardware" "opengl" "extraPackages32"])
  ];
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
    fzf
    git
  ];
}
