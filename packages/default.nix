{ pkgs, ... }:
{
  rtl8188eu = pkgs.callPackage ./os-specific/linux/firmware/rtl8188eu.nix {};
}
