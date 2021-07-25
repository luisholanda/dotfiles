{
  description = "My Nix configurations.";

  inputs =
  {
    nixpkgs.url = "nixpkgs/master";
    home-manager.url = "github:rycee/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ { self, nixpkgs, ... }: let
    inherit (lib) nameValuePair;
    inherit (lib.my) mapModulesRec mapModulesRec' mkHost mkHostsFromDir;
    system = builtins.currentSystem;
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
      overlays = [ self.overlay ] ++ (nixpkgs.lib.attrValues self.overlays);
    };

    lib = nixpkgs.lib.extend
      (self: super: { my = import ./lib { inherit pkgs inputs; lib = self; }; });

    dotfiles = import ./.;
  in {
    overlay = final: prev: self.packages."${system}";

    overlays = mapModulesRec ./overlays import;
    packages."${system}" = import ./packages { inherit pkgs; };

    nixosModules = { inherit dotfiles; } // mapModulesRec ./modules import;

    #nixosConfigurations = mkHostsFromDir ./hosts {
    #  inherit dotfiles;
    #  home-manager = inputs.home-manager.nixosModule;
    #};
    nixosConfigurations = {
      plutus = mkHost ./hosts/plutus {
        inherit dotfiles;
        home-manager = inputs.home-manager.nixosModule;
      };
    };

    devShell."${system}" = import ./shell.nix { inherit pkgs; };

    templates = {
      full = {
        path = ./.;
        description = "A completely non-minimal NixOS configuration";
      };
    };
  };
}
