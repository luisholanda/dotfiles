{ inputs, config, lib, pkgs, ... }:
let
  inherit (builtins) map;
  inherit (lib) filterAttrs mapAttrs mapAttrsToList mkDefault mkIf;
  inherit (lib.my)  mapModulesRec';
  inherit (pkgs.stdenv) isDarwin;
in {
  imports = (mapModulesRec' (toString ./modules) import);

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  environment.variables.NIXPKGS_ALLOW_UNFREE = "1";
  nix = let
    filteredInputs = filterAttrs (n: _: n != "self") inputs;
    nixPathInputs = mapAttrsToList (n: v: "${n}=${v}") filteredInputs;
    registryInputs = mapAttrs (_: v: { flake = v; }) filteredInputs;
    mkCache = url: key: { inherit url key; };
    caches = let
      nixos = mkCache "https://cache.nixos.org"
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=";
      cachix = mkCache "https://cachix.cachix.org"
        "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM=";
      nix-tools = mkCache "https://nix-tools.cachix.org"
        "nix-tools.cachix.org-1:ebBEBZLogLxcCvipq2MTvuHlP7ZRdkazFSQsbs0Px1A=";
      nix-community = mkCache "https://nix-community.cachix.org"
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";
    in [ nixos cachix nix-tools nix-community ];
  in {
    package = pkgs.nixFlakes;
    extraOptions = "experimental-features = nix-command flakes";
    nixPath = nixPathInputs ++ [
      "nixpkgs-overlays=${config.dotfiles.dir}/overlays"
      "dotfiles=${config.dotfiles.dir}"
    ];
    binaryCaches = map (x: x.url) caches;
    binaryCachePublicKeys = map (x: x.key) caches;
    registry = registryInputs // { dotfiles.flake = inputs.self; };
    autoOptimiseStore = true;
    useSandbox = true;
    sandboxPaths = [ ] ++ lib.optionals isDarwin [
      "/System/Library/Frameworks"
      "/System/Library/PrivateFrameworks"
      "/usr/lib"
      "/private/tmp"
      "/private/var/tmp"
      "/usr/bin/env"
    ];
  };
  system.configurationRevision = with inputs; mkIf (self ? rev) self.rev;
  system.stateVersion = "21.05";

  ## Reasonable global defaults
  # This is here to appease `nix flake check` for generic hosts with no
  # hardware-configuration.nix or fileSystem config.
  fileSystems."/".device = mkDefault "/dev/disk/by-label/nixos";

  boot = {
    kernelPackages = mkDefault pkgs.linuxPackages_5_10;
    loader = {
      efi.canTouchEfiVariables = mkDefault true;
      systemd-boot.configurationLimit = 10;
      systemd-boot.enable = mkDefault true;
    };
  };

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
