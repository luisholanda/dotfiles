{
  description = "My Nix configurations.";

  inputs =
    {
      nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
      home-manager.url = "github:rycee/home-manager/master";
      home-manager.inputs.nixpkgs.follows = "nixpkgs";
      agenix.url = "github:ryantm/agenix";
      agenix.inputs.nixpkgs.follows = "nixpkgs";
      flake-utils.url = "github:numtide/flake-utils";
    };

  outputs = inputs @ { self, nixpkgs, flake-utils, ... }:
    let
      dotfiles = import ./.;

      systemAttrs = flake-utils.lib.eachDefaultSystem (system:
        let
          inherit (lib) nameValuePair;
          inherit (lib.my) mapModulesRec mapModulesRec' mkHost mkHostsFromDir;

          overlays = mapModulesRec ./overlays import;

          # Base nixpkgs without our custom packages.
          #
          # Should only be used to build our packages.
          basePkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
            overlays = nixpkgs.lib.attrValues overlays;
          };

          packages = import ./packages { pkgs = basePkgs; };

          # Nixpkgs with our extra packages.
          pkgs = basePkgs // packages;

          lib = nixpkgs.lib.extend
            (self: super: { my = import ./lib { inherit pkgs inputs; lib = self; }; });
        in
        {
          inherit packages;

          devShell = import ./shell.nix { inherit pkgs; };

          nixosModules = { inherit dotfiles; } // mapModulesRec ./modules import;
          nixosConfigurations = {
            plutus = mkHost ./hosts/plutus {
              inherit dotfiles;
              modules = mapModulesRec' ./modules import ++ [
                inputs.home-manager.nixosModule
              ];
            };
          };
        });

      system = builtins.currentSystem;
    in
    systemAttrs // {
      nixosModules = systemAttrs.nixosModules."${system}";
      nixosConfigurations = systemAttrs.nixosConfigurations."${system}";

      templates = {
        full = {
          path = ./.;
          description = "A completely non-minimal NixOS configuration";
        };
      };
    };
}
