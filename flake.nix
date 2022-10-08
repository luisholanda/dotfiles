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

    emacs-overlay.url = "github:nix-community/emacs-overlay";
    emacs-overlay.inputs.flake-utils.follows = "flake-utils";
    emacs-overlay.inputs.nixpkgs.follows = "nixpkgs";

    doom-emacs.url = "github:doomemacs/doomemacs";
    doom-emacs.flake = false;
    git-stack.url = "github:gitext-rs/git-stack";
    git-stack.flake = false;
  };

  outputs = inputs @ {
    nixpkgs,
    firefox-addons,
    flake-utils,
    pre-commit-hooks,
    devshell,
    emacs-overlay,
    doom-emacs,
    git-stack,
    ...
  }: let
    dotfiles = import ./.;

    systems = with flake-utils.lib.system; [
      x86_64-linux
      x86_64-darwin
      aarch64-darwin
    ];

    systemAttrs = flake-utils.lib.eachSystem systems (system: let
      inherit (lib.my) mapModulesRec mapModulesRec' mkHost;

      overlays = mapModulesRec' ./overlays import;

      # Base nixpkgs without our custom packages.
      #
      # Should only be used to build our packages.
      basePkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays =
          overlays
          ++ [
            devshell.overlay
            emacs-overlay.overlay
            (_final: _prev: {
              firefox.extensions = firefox-addons.packages.${system};
            })
            (_final: _prev: {
              inherit doom-emacs;
              srcs = {inherit git-stack;};
            })
          ];
      };

      packages = import ./packages {pkgs = basePkgs;};

      lib =
        nixpkgs.lib.extend
        (self: _super: {
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
          deadnix.enable = true;
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
    in rec {
      inherit packages;

      checks = {inherit pre-commit-check;};

      devShells.default = import ./shell.nix {inherit pkgs pre-commit-check;};

      nixosModules = {inherit dotfiles;} // mapModulesRec ./modules import;
      nixosConfigurations = let
        extraModules = [
          dotfiles
          inputs.home-manager.nixosModule
          {
            nix.nixPath = ["nixpkgs=${nixpkgs.outPath}"];
          }
        ];

        mkHost' = path:
          mkHost path {
            inherit dotfiles pkgs system inputs;
            modules = (mapModulesRec' ./modules import) ++ extraModules;
          };
      in {
        plutus = mkHost' ./hosts/plutus;
        hermes = mkHost' ./hosts/hermes;
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
