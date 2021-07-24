{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  name = "dotfiles";

  buildinputs = with pkgs; [
    gnumake
  ];
}
