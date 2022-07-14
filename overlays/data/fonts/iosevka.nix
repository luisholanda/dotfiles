final: prev: let
  inherit (final) nerd-font-patcher;

  privateBuildPlan = {
    family = "Iosevka Custom";
    spacing = "quasi-proportional";
    serifs = "sans";
    no-cv-ss = true;

    variants.inherits = "ss08";
    ligations.inherits = "dlig";
    widths.normal = {
      shape = 600;
      menu = 5;
      css = "normal";
    };
  };

  customizedIosevka = prev.iosevka.override {
    inherit privateBuildPlan;

    set = "custom";
  };
in {
  iosevka-custom = final.stdenv.mkDerivation {
    pname = "iosevka-custom-nerdfont";
    inherit (customizedIosevka) version;

    nativeBuildInputs = [
      nerd-font-patcher
    ];

    src = customizedIosevka;

    buildPhase = ''
      runHook preBuild
      fontdir="$src/share/fonts/truetype"
      for font in $fontdir/*; do
        nerd-font-patcher $font \
          --adjust-line-height \
          --complete \
          --careful \
          --outputdir ttfs
      done
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      fontdir="$out/share/fonts/truetype"
      mkdir -p "$fontdir"
      mv ttfs/* "$fontdir"
      runHook postInstall
    '';
  };
}
