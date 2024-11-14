{
  lib,
  system,
  ...
}: let
  inherit (lib.my) mapModules;
  inherit (lib) hasSuffix;
in rec {
  # Create a new host based on a given path.
  mkHost = path: {
    system,
    pkgs,
    inputs,
    systemFn,
    modules ? [],
    ...
  }: let
    inherit (builtins) baseNameOf;
    inherit (pkgs.lib) mkDefault removeSuffix;
    inherit (pkgs) lib;
  in
    systemFn {
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

  isLinux = hasSuffix "-linux" system;
  isDarwin = hasSuffix "-darwin" system;
}
