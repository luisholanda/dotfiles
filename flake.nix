{
  description = "My Nix configurations.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager.url = "github:rycee/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    flake-utils.url = "github:numtide/flake-utils";

    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
    pre-commit-hooks.inputs.flake-utils.follows = "flake-utils";
    pre-commit-hooks.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-utils,
    pre-commit-hooks,
    ...
  }: let
    dotfiles = import ./.;

    systems = with flake-utils.lib.system; [
      x86_64-linux
      x86_64-darwin
      aarch64-darwin
    ];

    systemAttrs = flake-utils.lib.eachSystem systems (system: let
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

      packages = import ./packages {pkgs = basePkgs;};

      # Nixpkgs with our extra packages.
      pkgs = basePkgs // packages;

      lib =
        nixpkgs.lib.extend
        (self: super: {
          my = import ./lib {
            inherit pkgs inputs;
            lib = self;
          };
        });

      pre-commit-check = pre-commit-hooks.lib.${system}.run {
        src = ./.;
        hooks = {
          alejandra.enable = true;
          statix.enable = true;

          stylua = {
            enable = true;
            name = "stylua";
            description = "An Opinionated Lua Code Formatter";
            types = ["file" "lua"];
            entry = "${pkgs.stylua}/bin/stylua";
          };
        };
      };
    in {
      inherit packages;

      checks = {inherit pre-commit-check;};

      devShell = pkgs.mkShell {
        name = "dotfiles";

        buildinputs = with pkgs; [
          gnumake
        ];

        shellHook = ''
          ${pre-commit-check.shellHook}
        '';
      };

      nixosModules = {inherit dotfiles;} // mapModulesRec ./modules import;
      nixosConfigurations = {
        plutus = mkHost ./hosts/plutus {
          inherit dotfiles;
          modules =
            mapModulesRec' ./modules import
            ++ [
              inputs.home-manager.nixosModule
            ];
        };
      };
    });

    system = builtins.currentSystem;
  in
    systemAttrs
    // {
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
