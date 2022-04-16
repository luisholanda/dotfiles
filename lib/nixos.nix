{
  inputs,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.my; let
  sys = "x86_64-linux";
in {
  # Create a new host based on a given path.
  mkHost = path: attrs @ {
    system ? sys,
    modules ? [],
    ...
  }:
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
  mkHostsFromDir = dir: attrs @ {system ? sys, ...}:
    mapModules dir (hostPath: mkHost hostPath attrs);
}
