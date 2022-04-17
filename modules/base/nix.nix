{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (pkgs.stdenv) isDarwin;

  mkCache = url: key: {inherit url key;};
  caches = let
    nixos =
      mkCache "https://cache.nixos.org"
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=";
    cachix =
      mkCache "https://cachix.cachix.org"
      "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM=";
    nix-tools =
      mkCache "https://nix-tools.cachix.org"
      "nix-tools.cachix.org-1:ebBEBZLogLxcCvipq2MTvuHlP7ZRdkazFSQsbs0Px1A=";
    nix-community =
      mkCache "https://nix-community.cachix.org"
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";
  in [nixos cachix nix-tools nix-community];

  binaryCaches = map (x: x.url) caches;
in {
  config = {
    nix.binaryCaches = binaryCaches;

    nix.package = pkgs.nixUnstable;
    nix.extraOptions = ''
      experimental-features = nix-command flakes
    '';
    nix.autoOptimiseStore = true;
    nix.allowedUsers = ["@whell" "@builders"];
    nix.useSandbox = true;
    nix.sandboxPaths = lib.optionals isDarwin [
      "/System/Library/Frameworks"
      "/System/Library/PrivateFrameworks"
      "/usr/lib"
      "/private/tmp"
      "/private/var/tmp"
      "/usr/bin/env"
    ];

    nix.binaryCachePublicKeys = map (x: x.key) caches;
    nix.trustedBinaryCaches = binaryCaches;
  };
}
