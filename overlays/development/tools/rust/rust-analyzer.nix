final: _: let
  inherit (final) rustPlatform fetchFromGitHub lib cmake stdenv CoreServices libiconv;
in {
  rust-analyzer-unwrapped = rustPlatform.buildRustPackage rec {
    pname = "rust-analyzer-unwrapped";
    version = "2023-09-18";
    cargoSha256 = "sha256-quX7e8Dw58pUpro3XKuY9TtrlK/gDiyvFN/Z8rxQw7Y=";

    src = fetchFromGitHub {
      owner = "rust-lang";
      repo = "rust-analyzer";
      rev = version;
      sha256 = "sha256-+d/GW4MyksvJmNoQLJMpKxApuZTVwaT+yuxxR/Cc/BE=";
    };

    cargoBuildFlags = ["--bin" "rust-analyzer" "--bin" "rust-analyzer-proc-macro-srv"];
    cargoTestFlags = ["--package" "rust-analyzer" "--package" "proc-macro-srv-cli"];

    # Code format check requires more dependencies but don't really matter for packaging.
    # So just ignore it.
    checkFlags = ["--skip=tidy::check_code_formatting"];

    nativeBuildInputs = [cmake];

    buildInputs = lib.optionals stdenv.isDarwin [
      CoreServices
      libiconv
    ];

    buildFeatures = ["mimalloc"];

    CFG_RELEASE = version;

    doCheck = false;

    doInstallCheck = true;
    installCheckPhase = ''
      runHook preInstallCheck
      versionOutput="$($out/bin/rust-analyzer --version)"
      echo "'rust-analyzer --version' returns: $versionOutput"
      [[ "$versionOutput" == "rust-analyzer ${version}" ]]
      runHook postInstallCheck
    '';

    meta = with lib; {
      description = "A modular compiler frontend for the Rust language";
      homepage = "https://rust-analyzer.github.io";
      license = with licenses; [mit asl20];
      maintainers = with maintainers; [oxalica];
      mainProgram = "rust-analyzer";
    };
  };
}
