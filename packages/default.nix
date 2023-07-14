{
  pkgs,
  system,
  lib,
  ...
}: let
  # Can't use pkgs.stdenv due to infinite recursion.
  inherit (lib) hasSuffix optionalAttrs;
  isLinux = hasSuffix "-linux" system;
  callPackage = path: pkgs.callPackage path {};

  linuxPackages = {
    rtl8188eu = callPackage ./os-specific/linux/firmware/rtl8188eu.nix;
  };
in
  {
    pragmasevka = callPackage ./data/fonts/pragmasevka.nix;
  }
  // (optionalAttrs isLinux linuxPackages)
