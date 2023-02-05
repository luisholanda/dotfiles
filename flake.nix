{
  description = "My Nix configurations.";

  inputs = {
    nixpkgs.url = "github:luisholanda/nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
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

    hyprland = {
      url = "github:hyprwm/Hyprland";
      # build with your own instance of nixpkgs
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
    hyprland,
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
              hyprland = hyprland.packages.${system}.default;
              steam = _prev.steam.override {
                extraPkgs = pkgs:
                  with pkgs; [
                    xorg.libXcursor
                    xorg.libXi
                    xorg.libXinerama
                    xorg.libXScrnSaver
                    libpng
                    libpulseaudio
                    libvorbis
                    stdenv.cc.cc.lib
                    libkrb5
                    keyutils
                  ];
              };
            })
            (final: _prev: {
              inherit doom-emacs;
              srcs = {inherit git-stack;};
              unstable = final;
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
          path = ./.;
          description = "A completely non-minimal NixOS configuration";
        };
      };
    };
}
