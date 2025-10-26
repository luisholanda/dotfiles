final: _: let
  inherit (final) lib stdenv;
in {
  rust-analyzer-unwrapped = final.unstable.rustPlatform.buildRustPackage rec {
    pname = "rust-analyzer-unwrapped";
    version = "2025-08-25";

    cargoHash = "sha256-G1R3IiKbQg1Dl6OFJSto0w4c18OUIrAPRiM/YStfkl0=";

    src = final.fetchFromGitHub {
      owner = "rust-lang";
      repo = "rust-analyzer";
      rev = "8747cf81540bd1bbbab9ee2702f12c33aa887b46";
      hash = "sha256-apbJj2tsJkL2l+7Or9tJm1Mt5QPB6w/zIyDkCx8pfvk=";
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
      # FIXME: Pass overrided `rust-analyzer` once `buildRustPackage` also implements #119942
      # FIXME: test script can't find rust std lib so hover doesn't return expected result
      # https://github.com/NixOS/nixpkgs/pull/354304
      # tests.neovim-lsp = callPackage ./test-neovim-lsp.nix { };
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
