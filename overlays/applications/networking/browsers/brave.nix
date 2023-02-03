_final: prev: let
  version = "1.47.186";
  url = "https://github.com/brave/brave-browser/releases/download/v${version}/brave-browser_${version}_amd64.deb";
in {
  brave = prev.brave.overrideAttrs (_: {
    inherit version;

    src = builtins.fetchurl {
      inherit url;
      sha256 = "sha256:1wkwqsw3n0s82xgcsjcrdhvkxx7m7rzf79kxf8z42z5yq26y9cp3";
    };
  });
}
