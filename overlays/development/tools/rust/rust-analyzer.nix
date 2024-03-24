final: _: {
  rust-analyzer-unwrapped = final.stdenv.mkDerivation rec {
    pname = "rust-analyzer-unwrapped";
    version = "2024-03-18";
    src = builtins.fetchurl {
      url = "https://github.com/rust-lang/rust-analyzer/releases/download/${version}/rust-analyzer-x86_64-unknown-linux-gnu.gz";
      sha256 = "sha256:1kdfs87fsxr25zrnmnswg8sllrrshn1riydbw2g5zymzv78yxz8j";
    };

    dontUnpack = true;

    nativeBuildInputs = with final; [gzip autoPatchelfHook];
    buildInputs = with final; [libgcc];

    doInstallCheck = true;
    installCheckPhase = ''
      runHook preInstallCheck
      versionOutput="$($out/bin/rust-analyzer --version)"
      echo "'rust-analyzer --version' returns: $versionOutput"
      runHook postInstallCheck
    '';

    buildPhase = ''
      runHook preBuild
      mkdir -p $out/bin
      gzip -c -d $src > $out/bin/rust-analyzer
      chmod +x $out/bin/rust-analyzer
      runHook postBuild
    '';
  };
}
