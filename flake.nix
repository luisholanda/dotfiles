{
  description = "My Nix configurations.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";

    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    stylix.url = "github:danth/stylix/release-24.05";
    stylix.inputs.nixpkgs.follows = "nixpkgs";
    stylix.inputs.home-manager.follows = "home-manager";
    stylix.inputs.flake-compat.follows = "pre-commit-hooks/flake-compat";

    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
    pre-commit-hooks.inputs.nixpkgs.follows = "nixpkgs";
    pre-commit-hooks.inputs.nixpkgs-stable.follows = "nixpkgs";

    firefox-addons.url = "github:nix-community/nur-combined?dir=repos/rycee/pkgs/firefox-addons";
    firefox-addons.inputs.flake-utils.follows = "flake-utils";
    firefox-addons.inputs.nixpkgs.follows = "nixpkgs";

    # Current HEAD causes problems.
    emacs-overlay.url = "github:nix-community/emacs-overlay";
    emacs-overlay.inputs.nixpkgs.follows = "nixpkgs";
    emacs-overlay.inputs.nixpkgs-stable.follows = "nixpkgs";

    zig-overlay.url = "github:mitchellh/zig-overlay";
    zig-overlay.inputs.flake-compat.follows = "pre-commit-hooks/flake-compat";
    zig-overlay.inputs.flake-utils.follows = "flake-utils";
    zig-overlay.inputs.nixpkgs.follows = "nixpkgs";

    zls.url = "github:zigtools/zls";
    zls.inputs.nixpkgs.follows = "nixpkgs";
    zls.inputs.flake-utils.follows = "flake-utils";
    zls.inputs.gitignore.follows = "pre-commit-hooks/gitignore";
    zls.inputs.zig-overlay.follows = "zig-overlay";

    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
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
          #"electron-25.9.0"
          "electron-27.3.11"
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
            (_: prev: {
              inherit (zls.packages.${system}) zls;
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
      packages.nixosConfigurations = let
        extraModules = [
          dotfiles
          inputs.home-manager.nixosModule
          inputs.stylix.nixosModules.stylix
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
      };
    });
  in
    systemAttrs
    // {
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
