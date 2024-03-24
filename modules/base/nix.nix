{
  config,
  pkgs,
  ...
}: let
  mkCache = url: key: {inherit url key;};
  caches = let
    nixos =
      mkCache "https://cache.nixos.org"
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=";
    cachix =
      mkCache "https://cachix.cachix.org"
      "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM=";
    nix-community =
      mkCache "https://nix-community.cachix.org"
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";
  in [nixos cachix nix-community];

  binaryCaches = map (x: x.url) caches;
in {
  config = {
    nix.package = pkgs.nixUnstable;

    nix.settings = {
      substituters = binaryCaches;
      auto-optimise-store = true;
      allowed-users = ["@whell" "@builders"];
      #sandbox-paths = lib.optionals isDarwin [
      #  "/System/Library/Frameworks"
      #  "/System/Library/PrivateFrameworks"
      #  "/usr/lib"
      #  "/private/tmp"
      #  "/private/var/tmp"
      #  "/usr/bin/env"
      #];
      trusted-public-keys = map (x: x.key) caches;
      trusted-substituters = binaryCaches;
      experimental-features = "nix-command flakes";
      max-jobs = "auto";
      sandbox = true;
    };

    #nix.extraOptions = ''
    #  include ${config.dotfiles.dir}/nix-access-tokens
    #'';

    system.stateVersion = "22.05";
  };
}
