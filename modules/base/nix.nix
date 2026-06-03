{
  pkgs,
  lib,
  inputs,
  ...
}: {
  config = {
    nix.package = pkgs.unstable.lixPackageSets.latest.lix;
    nix.optimise.automatic = true;

    nix.settings = {
      substituters = lib.mkForce ["http://localhost:6543"];
      allowed-users = ["@whell" "@builders"];
      experimental-features = "nix-command flakes";
      max-jobs = "auto";
      sandbox = true;
    };

    services.ncro = {
      enable = true;
      package = inputs.ncro.packages.${pkgs.system}.default;
      settings = {
        server.listen = ":6543";

        cache.ttl = "30d";
        cache.negative_ttl = "1d";

        upstreams = [
          {
            url = "https://cache.nixos.org";
            public_key = "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=";
          }
          {
            url = "https://cachix.cachix.org";
            public_key = "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM=";
          }
          {
            url = "https://nix-community.cachix.org";
            public_key = "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";
          }
          {
            url = "https://hyprland.cachix.org";
            public_key = "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=";
          }
          {
            url = "https://nix-tools.cachix.org";
            public_key = "nix-tools.cachix.org-1:ebBEBZLogLxcCvipq2MTvuHlP7ZRdkazFSQsbs0Px1A=";
          }
        ];
      };
    };
  };
}
