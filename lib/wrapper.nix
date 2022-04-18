{
  pkgs,
  lib,
  ...
}: let
  inherit (pkgs) makeWrapper;
  inherit (lib) getName makeBinPath;
in {
  addToPath = pkg: newPkgs:
    pkgs.runCommandLocal ((getName pkg) + "-wrapped") {
      src = [pkg];
      buildInputs = [makeWrapper];
    } ''
      cp -a ${makeBinPath [pkg]} $out/bin

      for bin in $(find $out/bin -type f); do
        wrapProgram $bin \
          --prefix PATH : ${makeBinPath newPkgs};
      done
    '';
}
