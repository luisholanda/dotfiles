{lib, ...}: let
  inherit (lib.my) mapModules;
in rec {
  # Create a new host based on a given path.
  mkHost = path: {
    system,
    pkgs,
    inputs,
    modules ? [],
    ...
  }: let
    inherit (builtins) baseNameOf;
    inherit (pkgs.lib) mkDefault nixosSystem removeSuffix;
    inherit (pkgs) lib;
  in
    nixosSystem {
      inherit system;
      specialArgs = {inherit lib inputs system;};
      modules =
        [
          {
            nixpkgs.pkgs = pkgs;
            networking.hostName = mkDefault (removeSuffix ".nix" (baseNameOf path));
          }
          (import path)
        ]
        ++ modules;
    };

  # Create new hosts from every path inside dir.
  mkHostsFromDir = dir: attrs:
    mapModules dir (hostPath: mkHost hostPath attrs);
}
