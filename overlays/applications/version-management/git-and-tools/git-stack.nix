final: prev: let
  inherit (final.rustPlatform) buildRustPackage;
  inherit (final.srcs) git-stack;
in {
  gitAndTools =
    prev.gitAndTools
    // {
      git-stack = buildRustPackage {
        pname = "git-stack";
        version = "0.8.2";

        src = git-stack;

        cargoSha256 = "sha256-iwUZ4sJBzopRUcjerNug1TFe0eJWM6v8WsqZWVuvhD8=";

        # FIXME: we need to configure Git to run tests.
        doCheck = false;

        meta = with final.lib; {
          description = "Stacked branch management for Git";
          homepage = "https://github.com/gitext-rs/git-stack";
          license = licenses.mit;
        };
      };
    };
}
