{
  pkgs,
  lib,
  ...
}: let
  inherit (pkgs) makeWrapper runCommandLocal;
  inherit (lib) getName makeBinPath mapAttrsToList flatten escapeShellArg;

  translateWrapArg = v:
    if builtins.isList v
    then escapeShellArg (builtins.concatStringsSep ":" v)
    else escapeShellArg (builtins.toString v);

  wrapProgram = pkg: wrapArgs: let
    prefix =
      mapAttrsToList
      (n: v: "--prefix ${n} : ${translateWrapArg v}")
      (wrapArgs.prefix or {});

    set =
      mapAttrsToList
      (n: v: "--set ${n} ${translateWrapArg v}")
      (wrapArgs.set or {});

    wrapProgramArgs = builtins.concatStringsSep " " (flatten [prefix set]);
  in
    runCommandLocal ((getName pkg) + "-wrapped") {
      src = [pkg];
      buildInputs = [makeWrapper];
    } ''
      mkdir -p $out/bin

      for bin in $(find ${pkg}/bin -not -name '.*' -a \( -type f -o -type l \) ); do
        ln -s $(realpath $bin) $out/bin/$(basename $bin)
        wrapProgram $out/bin/$(basename $bin) ${wrapProgramArgs};
      done
    '';
in {
  inherit wrapProgram;

  addToPath = pkg: newPkgs:
    wrapProgram pkg {
      prefix.PATH = makeBinPath newPkgs;
    };
}
