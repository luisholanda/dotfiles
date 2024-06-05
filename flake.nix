{
  description = "My Nix configurations.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-23.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";

    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    stylix.url = "github:danth/stylix/release-23.11";
    stylix.inputs.nixpkgs.follows = "nixpkgs";
    stylix.inputs.home-manager.follows = "home-manager";
    stylix.inputs.flake-compat.follows = "pre-commit-hooks/flake-compat";

    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
    pre-commit-hooks.inputs.flake-utils.follows = "flake-utils";
    pre-commit-hooks.inputs.nixpkgs.follows = "nixpkgs";
    pre-commit-hooks.inputs.nixpkgs-stable.follows = "nixpkgs";

    firefox-addons.url = "github:nix-community/nur-combined?dir=repos/rycee/pkgs/firefox-addons";
    firefox-addons.inputs.flake-utils.follows = "flake-utils";
    firefox-addons.inputs.nixpkgs.follows = "nixpkgs";

    # Current HEAD causes problems.
    emacs-overlay.url = "github:nix-community/emacs-overlay?rev=a3abd804a0f05d3d388a6efced4f7bf50792deb6";
    emacs-overlay.inputs.flake-utils.follows = "flake-utils";
    emacs-overlay.inputs.nixpkgs.follows = "nixpkgs";

    hyprland.url = "github:hyprwm/Hyprland?rev=89543e8e3cb7d3d3e1755649779c3835bd5c5fd9";

    zig-overlay.url = "github:mitchellh/zig-overlay";
    zig-overlay.inputs.flake-utils.follows = "flake-utils";
    zig-overlay.inputs.nixpkgs.follows = "nixpkgs";

    zls.url = "github:zigtools/zls";
    zls.inputs.nixpkgs.follows = "nixpkgs";
    zls.inputs.flake-utils.follows = "flake-utils";
    zls.inputs.gitignore.follows = "pre-commit-hooks/gitignore";
    zls.inputs.zig-overlay.follows = "zig-overlay";

    nvchad.url = "github:nvchad/nvchad/v2.5";
    nvchad.flake = false;

    chaotic.url = "github:chaotic-cx/nyx?rev=2952a351037582a8aeb11be9cf57901d872bcf30";
    chaotic.inputs.home-manager.follows = "home-manager";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    nixpkgs-unstable,
    firefox-addons,
    flake-utils,
    pre-commit-hooks,
    emacs-overlay,
    hyprland,
    zls,
    chaotic,
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
        config.permittedInsecurePackages = [
          "electron-25.9.0"
        ];

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
            emacs-overlay.overlay
            addVendoredPackages
            addCustomLibFunctions
            addFirefoxExtensions
            (final: prev: {
              inherit (zls.packages.${system}) zls;
              inherit (hyprland.packages.${system}) hyprland xdg-desktop-portal-hyprland;
              unstable = import nixpkgs-unstable {
                inherit system;
                config.allowUnfree = true;
              };
              waybar =
                (prev.waybar.override {
                  withMediaPlayer = true;
                })
                .overrideAttrs (o: {
                  mesonFlags = o.mesonFlags ++ ["-Dexperimental=true"];
                });
              libsecret = prev.libsecret.overrideAttrs (_: {doCheck = false;});
              upower = prev.upower.overrideAttrs (_: {doCheck = false;});
              xdg-desktop-portal = final.xdg-desktop-portal-hyprland;
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

      devShells.default = pkgs.mkShell {
        inherit (pre-commit-check) shellHook;
        name = "dotfiles";

        buildInputs = with pkgs; [gnumake python3];
      };

      nixosModules = {inherit dotfiles;} // mapModulesRec ./modules import;
      nixosConfigurations = let
        extraModules = [
          dotfiles
          inputs.home-manager.nixosModule
          inputs.stylix.nixosModules.stylix
          hyprland.nixosModules.default
          chaotic.nixosModules.default
          {
            config.nix.nixPath = ["nixpkgs=${nixpkgs.outPath}"];
          }
        ];

        mkHost' = path:
          mkHost path {
            inherit dotfiles pkgs system inputs;
            modules = (mapModulesRec' ./modules import) ++ extraModules;
          };
      in {
        ares = mkHost' ./hosts/ares;
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
  nixConfig = {
    extra-substituters = [
      "https://hyprland.cachix.org"
      "https://nix-tools.cachix.org"
      "https://helix.cachix.org"
    ];
    extra-trusted-public-keys = [
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "nix-tools.cachix.org-1:ebBEBZLogLxcCvipq2MTvuHlP7ZRdkazFSQsbs0Px1A="
      "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs="
    ];
  };
}
