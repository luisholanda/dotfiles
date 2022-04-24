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
      mkdir -p $out/bin

      for bin in $(find ${pkg}/bin -type f); do
        ln -s $bin $out/bin/$(basename $bin)
        wrapProgram $out/bin/$(basename $bin) \
          --prefix PATH : ${makeBinPath newPkgs};
      done
    '';
}
