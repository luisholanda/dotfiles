{
  description = "My Nix configurations.";

  inputs =
  {
    nixpkgs.url = "nixpkgs/master";    # for packages on the edge
    home-manager.url = "github:rycee/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ { self, nixpkgs }: let
    inherit (lib.my) mapModules mapModulesRec mkHostsFromDir;
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
      overlays = [ self.overlay ] ++ self.overlays;
    };

    lib = nixpkgs.lib.extend
      (self: super: { my = import ./lib { inherit pkgs inputs; lib = self; }; });
  in {
    lib = lib.my;

    overlay = final: prev: { my = self.packages."${system}"; };

    overlays = mapModules ./overlays import;
    packages."${system}" = mapModules ./packages (p: pkgs.callPackage p {});

    nixosModules = { dotfiles = import ./.; } // mapModulesRec ./modules import;

    nixosConfiguration = mkHostsFromDir ./hosts {};
  };
}
