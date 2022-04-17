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

    devshell.url = "github:numtide/devshell";
    devshell.inputs.flake-utils.follows = "flake-utils";
    devshell.inputs.nixpkgs.follows = "nixpkgs";

    firefox-addons.url = "github:nix-community/nur-combined?dir=repos/rycee/pkgs/firefox-addons";
    firefox-addons.inputs.flake-utils.follows = "flake-utils";
    firefox-addons.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    firefox-addons,
    flake-utils,
    pre-commit-hooks,
    devshell,
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
        overlays =
          (nixpkgs.lib.attrValues overlays)
          ++ [
            devshell.overlay
            (final: prev: {
              firefox.extensions = firefox-addons.packages.${system};
            })
          ];
      };

      packages = import ./packages {pkgs = basePkgs;};

      lib =
        nixpkgs.lib.extend
        (self: super: {
          my = import ./lib {
            inherit inputs;
            pkgs = basePkgs;
            lib = self;
          };
        });

      # Nixpkgs with our extra packages.
      pkgs = basePkgs // packages // {inherit lib;};

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

      devShell = import ./shell.nix {inherit pkgs pre-commit-check;};

      nixosModules = {inherit dotfiles;} // mapModulesRec ./modules import;
      nixosConfigurations = {
        plutus = mkHost ./hosts/plutus {
          inherit dotfiles pkgs system inputs;
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
