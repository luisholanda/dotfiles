final: _: let
  inline-diagnostics = builtins.fetchurl {
    url = "https://patch-diff.githubusercontent.com/raw/helix-editor/helix/pull/6417.patch";
    sha256 = "sha256:0wjr3wvfh3h4l6cqa4p95c2ns066k53dnx39y8qbgm8kqf4d454y";
  };
  fix-completion-resolution = builtins.fetchurl {
    url = "https://patch-diff.githubusercontent.com/raw/helix-editor/helix/pull/10873.patch";
    sha256 = "sha256:0cn8rnih8jhqpmfw9hdd1w2kq2wimvvxqw75h3v0ajc2rpj7ga8s";
  };

  ts-grammars-links =
    final.lib.mapAttrsToList
    (name: artifact: "cp --no-preserve=mode,ownership ${artifact}/parser $out/lib/runtime/grammars/${final.lib.removePrefix "tree-sitter-" name}.so")
    (final.lib.filterAttrs (_: final.lib.isDerivation) final.unstable.tree-sitter-grammars);
in {
  helix = final.unstable.rustPlatform.buildRustPackage {
    pname = "helix";
    version = "24.03";

    doCheck = false;

    src = final.fetchFromGitHub {
      owner = "helix-editor";
      repo = "helix";
      rev = "c39cde8fc2a99871ff1ec9118d65ae404af9e702";
      sha256 = "sha256-6HqcZrRemA74n7mFWVUkt2fm4mfOp6/+hgGjBMYfAMA=";
    };

    cargoHash = "sha256-BEBg/+NIyeBzOAQJOIo/7L3LUNzmWfFKK8SGHeIB0Gc=";

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

    patches = [inline-diagnostics fix-completion-resolution];

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
