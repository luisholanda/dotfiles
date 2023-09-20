{
  pkgs,
  lib,
  ...
}: let
  inherit (pkgs) makeBinaryWrapper runCommandLocal;
  inherit (lib) getName makeBinPath mapAttrsToList flatten escapeShellArg escapeShellArgs;

  translateWrapArg = v:
    if builtins.isList v
    then escapeShellArgs v
    else escapeShellArg (builtins.toString v);

  wrapProgram = pkg: wrapArgs: let
    prefix =
      mapAttrsToList
      (n: v: "--prefix ${n} : ${translateWrapArg v}")
      (wrapArgs.prefix or {});

    suffix =
      mapAttrsToList
      (n: v: "--suffix ${n} : ${translateWrapArg v}")
      (wrapArgs.suffix or {});

    set =
      mapAttrsToList
      (n: v: "--set ${n} ${translateWrapArg v}")
      (wrapArgs.set or {});

    appendFlags =
      builtins.map
      (n: "--append-flags ${n}")
      (wrapArgs.appendFlags or []);

    wrapProgramArgs = builtins.concatStringsSep " " (flatten [set suffix prefix appendFlags]);
  in
    runCommandLocal ((getName pkg) + "-wrapped") {
      src = [pkg];
      buildInputs = [makeBinaryWrapper];
    } ''
      mkdir -p $out/bin

      for bin in $(find ${pkg}/bin -not -name '.*' -a \( -type f -o -type l \) ); do
        file="$(realpath $bin)"

        if [[ -f $file && -x $file ]]; then
          makeWrapper "$file" "$out/bin/$(basename $bin)" ${wrapProgramArgs};
        fi
      done
    '';
in {
  inherit wrapProgram;

  addToPath = pkg: newPkgs:
    wrapProgram pkg {
      prefix.PATH = makeBinPath newPkgs;
    };
}
