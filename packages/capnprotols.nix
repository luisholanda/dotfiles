{
  capnproto,
  capnproto-rust,
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage rec {
  pname = "capnprotols";
  version = "0.1.3";

  src = fetchFromGitHub {
    owner = "puremourning";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-LG+S06kQdgBpoF6pir/9KaOCtayOKu+n6tP2HaTx5bY=";
  };

  cargoHash = "sha256-crtlVzcx7/hIyfO4CwwaT+tgE+a8oPj0HqapAKkxzL0=";

  CAPNP_SCHEMA = "${capnproto}/include/capnp/schema.capnp";

  nativeBuildInputs = [
    capnproto
    capnproto-rust
  ];
}
