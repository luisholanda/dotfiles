final: prev: let
  inherit (final) fetchFromGitHub rustPlatform stdenv CoreServices libiconv cmake;
  inherit (final.lib) optionals;
in {
  rust-analyzer-unwrapped = rustPlatform.buildRustPackage rec {
    pname = "rust-analyzer-unwrapped";
    version = "2022-07-18";
    cargoSha256 = "sha256-XBVYZCZra+m1B7gcR5mB4EUCKUR5NdTAMc1WsrgxBag=";

    src = fetchFromGitHub {
      owner = "rust-lang";
      repo = "rust-analyzer";
      rev = version;
      sha256 = "sha256-HU1+Rql35ouZe0lx1ftCMDDwC9lqN3COudvMe+8XIx0=";
    };

    buildAndTestSubdir = "crates/rust-analyzer";

    nativeBuildInputs = [ cmake ];

    buildInputs = optionals stdenv.isDarwin [
      CoreServices
      libiconv
    ];

    buildFeatures = [ "mimalloc" ];

    RUST_ANALYZER_REV = version;

    doCheck = false;
    doInstallCheck = false;
  };
}
