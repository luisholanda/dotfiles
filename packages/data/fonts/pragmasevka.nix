{
  nerd-font-patcher,
  iosevka,
  stdenv,
}: let
  # This is not the _exactly_ plan for pragmasevka, I did some adjustments
  # to better fit the overall PragmataPro style.
  privateBuildPlan = {
    family = "Pragmasevka";
    serifs = "sans";
    no-cv-ss = true;
    export-glyph-names = true;

    hintParams = ["-a" "qqq"];

    ligations = {
      inherits = "default-calt";
      enables = [
        "eqslasheq"
        "kern-dotty"
        "kern-bars"
        "llggeq"
        "connected-underscore"
        "connected-number-sign"
        "connected-hyphen"
      ];
      disables = ["slash-asterisk"];
    };

    metric-override = {
      leaning = 1100;
      periodSize = "default_periodSize * 1.2";
      xHeight = 550;
    };

    slopes = {
      upright = "default.upright";
      italic = "default.italic";
    };

    variants = {
      inherits = "ss08";
      design = {
        number-sign = "slanted";
        capital-z = "curly-serifless";
        z = "curly-serifless";
        zero = "reverse-slashed-split-oval";
        underscore = "high";
        lig-ltgteq = "flat";
        lig-neq = "slightly-slanted";
        lig-equal-chain = "with-notch";
        lig-hyphen-chain = "with-notch";
        lig-double-arrow-bar = "with-notch";
        lig-single-arrow-bar = "with-notch";
      };
    };

    weights = {
      regular = {
        shape = 425;
        menu = 400;
        css = 400;
      };
      semibold = {
        shape = 600;
        menu = 600;
        css = 600;
      };
      bold = {
        shape = 800;
        menu = 700;
        css = 700;
      };
      black = {
        shape = 900;
        menu = 900;
        css = 900;
      };
    };

    widths.normal = {
      shape = 600;
      menu = 5;
      css = "normal";
    };
  };

  pragmasevka = iosevka.override {
    inherit privateBuildPlan;

    set = "custom";
  };
in
  stdenv.mkDerivation {
    name = "pragmasevka-nerdfont";
    inherit (pragmasevka) version;

    nativeBuildInputs = [
      nerd-font-patcher
    ];

    src = pragmasevka;

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
  }
