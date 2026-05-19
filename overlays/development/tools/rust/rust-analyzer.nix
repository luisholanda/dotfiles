final: _: let
  inherit (final) lib stdenv;
in {
  rust-analyzer-unwrapped = final.unstable.rustPlatform.buildRustPackage rec {
    pname = "rust-analyzer-unwrapped";
    version = "2026-03-30";

    cargoHash = "sha256-nTllacWD0alq8OVKAPhcuMnAyPW2Uh0JAJkHhB9YcZ4=";

    src = final.fetchFromGitHub {
      owner = "rust-lang";
      repo = "rust-analyzer";
      rev = version;
      hash = "sha256-Cbpmf0+1pqi/zbpub2vkp5lTPx3QdVtDkkagDwQzHHg=";
    };

    cargoBuildFlags = [
      "--bin"
      "rust-analyzer"
      "--bin"
      "rust-analyzer-proc-macro-srv"
    ];
    cargoTestFlags = [
      "--package"
      "rust-analyzer"
      "--package"
      "proc-macro-srv-cli"
    ];

    # Code format check requires more dependencies but don't really matter for packaging.
    # So just ignore it.
    checkFlags = ["--skip=tidy::check_code_formatting"];

    nativeBuildInputs = [final.cmake];

    buildInputs = lib.optionals stdenv.hostPlatform.isDarwin [
      final.libiconv
    ];

    buildFeatures = ["mimalloc"];

    env.CFG_RELEASE = version;

    doCheck = false;

    doInstallCheck = true;
    installCheckPhase = ''
      runHook preInstallCheck
      versionOutput="$($out/bin/rust-analyzer --version)"
      echo "'rust-analyzer --version' returns: $versionOutput"
      [[ "$versionOutput" == "rust-analyzer ${version}" ]]
      runHook postInstallCheck
    '';

    passthru = {
      updateScript = final.nix-update-script {};
    };

    meta = with lib; {
      description = "Modular compiler frontend for the Rust language";
      homepage = "https://rust-analyzer.github.io";
      license = with licenses; [
        mit
        asl20
      ];
      maintainers = with maintainers; [oxalica];
      mainProgram = "rust-analyzer";
    };
  };
}
