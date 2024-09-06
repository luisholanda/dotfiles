final: _: {
  rust-analyzer-unwrapped = final.stdenv.mkDerivation rec {
    pname = "rust-analyzer-unwrapped";
    version = "2024-09-02";
    src = builtins.fetchurl {
      url = "https://github.com/rust-lang/rust-analyzer/releases/download/${version}/rust-analyzer-x86_64-unknown-linux-gnu.gz";
      sha256 = "sha256:1ia4qbd3v2dqf6f02mb746rhbvilhypqagdsf1rd47k8cdwn14zi";
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
