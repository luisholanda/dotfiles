final: _: {
  rust-analyzer-unwrapped = final.stdenv.mkDerivation rec {
    pname = "rust-analyzer-unwrapped";
    version = "2024-05-27";
    src = builtins.fetchurl {
      url = "https://github.com/rust-lang/rust-analyzer/releases/download/${version}/rust-analyzer-x86_64-unknown-linux-gnu.gz";
      sha256 = "sha256:1mmg6j5qq0ikai12sa027ahv9ms0prfahggby5nsyw9qm8mif4h6";
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
