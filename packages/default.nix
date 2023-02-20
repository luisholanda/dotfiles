{pkgs, ...}: let
  inherit (pkgs.stdenv) isLinux;
  inherit (pkgs.lib) optionalAttrs;

  linuxPackages = {
    rtl8188eu = pkgs.callPackage ./os-specific/linux/firmware/rtl8188eu.nix {};
  };
in
  {
    iosevka = pkgs.callPackage ./data/fonts/iosevka.nix {};
  }
  // (optionalAttrs isLinux linuxPackages)
