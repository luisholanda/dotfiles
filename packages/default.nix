{
  pkgs,
  system,
  lib,
  ...
}: let
  # Can't use pkgs.stdenv due to infinite recursion.
  inherit (lib) hasSuffix optionalAttrs;
  isLinux = hasSuffix "-linux" system;

  linuxPackages = {
    rtl8188eu = pkgs.callPackage ./os-specific/linux/firmware/rtl8188eu.nix {};
  };
in
  {
    iosevka = pkgs.callPackage ./data/fonts/iosevka.nix {};
  }
  // (optionalAttrs isLinux linuxPackages)
