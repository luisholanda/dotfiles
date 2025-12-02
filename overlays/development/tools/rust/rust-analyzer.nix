final: _: let
  inherit (final) lib stdenv;
in {
  rust-analyzer-unwrapped = final.unstable.rustPlatform.buildRustPackage rec {
    pname = "rust-analyzer-unwrapped";
    version = "2025-12-01";

    cargoHash = "sha256-ChsaWQ4gfBuucdab1uRw7tCZJcqDn9drwyAqQ6b4Dac=";

    src = final.fetchFromGitHub {
      owner = "rust-lang";
      repo = "rust-analyzer";
      rev = version;
      hash = "sha256-vR3vU9AwzMsBvjNeeG2inA5W/2MwseFk5NIIrLFEMHk=";
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
