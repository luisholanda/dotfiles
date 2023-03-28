{
  description = "My Nix configurations.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.inputs.utils.follows = "flake-utils";

    flake-utils.url = "github:numtide/flake-utils";

    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
    pre-commit-hooks.inputs.flake-utils.follows = "flake-utils";
    pre-commit-hooks.inputs.nixpkgs.follows = "nixpkgs";
    pre-commit-hooks.inputs.nixpkgs-stable.follows = "nixpkgs";

    devshell.url = "github:numtide/devshell";
    devshell.inputs.flake-utils.follows = "flake-utils";
    devshell.inputs.nixpkgs.follows = "nixpkgs";

    firefox-addons.url = "github:nix-community/nur-combined?dir=repos/rycee/pkgs/firefox-addons";
    firefox-addons.inputs.flake-utils.follows = "flake-utils";
    firefox-addons.inputs.nixpkgs.follows = "nixpkgs";

    emacs-overlay.url = "github:nix-community/emacs-overlay";
    emacs-overlay.inputs.flake-utils.follows = "flake-utils";
    emacs-overlay.inputs.nixpkgs.follows = "nixpkgs";

    git-stack.url = "github:gitext-rs/git-stack";
    git-stack.flake = false;

    hyprland = {
      url = "github:hyprwm/Hyprland";
      # build with your own instance of nixpkgs
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    firefox-addons,
    flake-utils,
    pre-commit-hooks,
    devshell,
    emacs-overlay,
    git-stack,
    hyprland,
    ...
  }: let
    dotfiles = import self.outPath;

    systems = with flake-utils.lib.system; [
      x86_64-linux
      x86_64-darwin
      aarch64-darwin
    ];

    systemAttrs = flake-utils.lib.eachSystem systems (system: let
      inherit (lib.my) mapModulesRec mapModulesRec' mkHost;

      overlays = mapModulesRec' ./overlays import;

      lib = nixpkgs.lib.extend (self: _super: {
        my = import ./lib {
          inherit inputs;
          pkgs = nixpkgs.legacyPackages.${system};
          lib = self;
        };
      });

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = let
          addVendoredPackages = final: _prev:
            import ./packages {
              inherit system lib;
              pkgs = final;
            };
          addCustomLibFunctions = _final: _prev: {inherit lib;};
          addFirefoxExtensions = _final: _prev: {firefox.extensions = firefox-addons.packages.${system};};
        in
          overlays
          ++ [
            devshell.overlay
            emacs-overlay.overlay
            hyprland.overlays.default
            addVendoredPackages
            addCustomLibFunctions
            addFirefoxExtensions
            (final: _prev: {
              srcs = {inherit git-stack;};
              unstable = final;
            })
          ];
      };

      pre-commit-check = pre-commit-hooks.lib.${system}.run {
        src = self.outPath;
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
    in {
      checks = {inherit pre-commit-check;};

      devShells.default = import ./shell.nix {inherit pkgs pre-commit-check;};

      nixosModules = {inherit dotfiles;} // mapModulesRec ./modules import;
      nixosConfigurations = let
        extraModules = [
          dotfiles
          inputs.home-manager.nixosModule
          hyprland.nixosModules.default
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
        ares = mkHost' ./hosts/ares;
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
          path = self.outPath;
          description = "A completely non-minimal NixOS configuration";
        };
      };
    };
}
