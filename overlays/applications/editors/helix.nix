final: _: let
  inline-diagnostics = builtins.fetchurl {
    url = "https://patch-diff.githubusercontent.com/raw/helix-editor/helix/pull/6417.patch";
    sha256 = "sha256:0wjr3wvfh3h4l6cqa4p95c2ns066k53dnx39y8qbgm8kqf4d454y";
  };

  src = final.fetchFromGitHub {
    owner = "helix-editor";
    repo = "helix";
    rev = "9c479e6d2de3bca9dec304f9182cee2b1c0ad766";
    sha256 = "sha256-/XOumFymqlUSS2OZZSOIUL7z1vQyxOEpuOqynH85aYI=";
  };

  ts-grammars-links = let
    languages-toml = builtins.fromTOML (builtins.readFile "${src}/languages.toml");
    grammars =
      builtins.listToAttrs
      (builtins.map (g: {
          inherit (g) name;
          value =
            (final.unstable.tree-sitter.buildGrammar {
              inherit (final.unstable.tree-sitter) version;
              language = g.name;
              src = builtins.fetchGit {
                inherit (g.source) rev;
                url = g.source.git;
                ref = g.source.ref or "HEAD";
                shallow = true;
                allRefs = true;
              };
              location = g.source.subpath or null;
            })
            .overrideAttrs (_: {allowSubstitutes = false;});
        })
        languages-toml.grammar);
  in
    final.lib.mapAttrsToList
    (name: artifact: "cp --no-preserve=mode,ownership ${artifact}/parser $out/lib/runtime/grammars/${name}.so")
    grammars;
in {
  helix = final.unstable.rustPlatform.buildRustPackage {
    inherit src;

    pname = "helix";
    version = "24.03";

    doCheck = false;

    cargoHash = "sha256-rt/FkUXQypehDqGEEHqjkWsPmJScbBY1IfqEV5Bpb6s=";

    nativeBuildInputs = with final; [git installShellFiles];

    env.HELIX_DEFAULT_RUNTIME = "${placeholder "out"}/lib/runtime";
    env.HELIX_DISABLE_AUTO_GRAMMAR_BUILD = "1";

    postInstall = ''
      mkdir -p $out/lib
      cp -r runtime $out/lib
      installShellCompletion contrib/completion/hx.{bash,fish,zsh}
      mkdir -p $out/share/{applications,icons/hicolor/256x256/apps}
      cp contrib/Helix.desktop $out/share/applications
      cp contrib/helix.png $out/share/icons/hicolor/256x256/apps

      ${builtins.concatStringsSep "\n" ts-grammars-links}
    '';

    patches = [inline-diagnostics];

    patchArgs = ["-p1" "--merge" "--force"];

    # HACK: inline-diagnostics conflicts in the book files, ignore any errors.
    patchPhase = ''
      runHook prePatch

      local -a patchesArray
      if [ -n "$__structuredAttrs" ]; then
          patchesArray=( ''${patches:+"''${patches[@]}"} )
      else
          patchesArray=( ''${patches:-} )
      fi

      set +e

      for i in "''${patchesArray[@]}"; do
          echo "applying patch $i"
          local uncompress=cat
          case "$i" in
              *.gz)
                  uncompress="gzip -d"
                  ;;
              *.bz2)
                  uncompress="bzip2 -d"
                  ;;
              *.xz)
                  uncompress="xz -d"
                  ;;
              *.lzma)
                  uncompress="lzma -d"
                  ;;
          esac

          local -a flagsArray
          if [ -n "$__structuredAttrs" ]; then
              flagsArray=( "''${patchFlags[@]:--p1}" )
          else
              # shellcheck disable=SC2086
              flagsArray=( ''${patchFlags:--p1} )
          fi
          # "2>&1" is a hack to make patch fail if the decompressor fails (nonexistent patch, etc.)
          # shellcheck disable=SC2086
          $uncompress < "$i" 2>&1 | patch "''${flagsArray[@]}"
      done

      set -e

      runHook postPatch
    '';
  };
}
