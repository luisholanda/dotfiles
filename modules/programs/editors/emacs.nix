{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption;
  inherit (pkgs) emacsWithPackagesFromUsePackage;
  inherit (config.theme) fonts;

  cfg = config.modules.editors.emacs;

  emacsConfigSource = config.dotfiles.configDir + "/emacs";
  emacsConfigFile = emacsConfigSource + "/config.org";
  nixEmacsConfigSource = lib.sourceByRegex emacsConfigSource ["config.org" "lisp" "lisp/.*.el$"];

  emacs =
    (pkgs.emacsWithPackagesFromUsePackage {
      config = emacsConfigFile;
      package = pkgs.emacsPgtkGcc;
      alwaysTangle = true;
      alwaysEnsure = true;

      extraEmacsPackages = epkgs: builtins.attrValues (import ./_customEmacsPlugins.nix {inherit pkgs epkgs;});
    })
    // {inherit (pkgs.emacsPgtkGcc) nativeComp;};

  trivialBuild = pkgs.emacsPackages.trivialBuild.override {inherit emacs;};

  init = trivialBuild {
    pname = "config-init";
    version = "dev";

    src = nixEmacsConfigSource;

    dontUnpack = true;

    preBuild = ''
      cp -a $src/* .
      # Tangle org files
      emacs --batch -Q \
        -l org \
        *.org \
        -f org-babel-tangle

      # Fake config directory in order to have files on load-path
      mkdir -p .xdg-config
      ln -s $PWD .xdg-config/emacs

      export XDG_CONFIG_HOME="$PWD/.xdg-config"

      # Custom variables bridge.
      export EMACS_MONO_FONT_FAMILY="${fonts.family.monospace}"
      export EMACS_VARIABLE_PITCH_FONT_FAMILY="${fonts.family.sansSerif}"
      export EMACS_SERIF_FONT_FAMILY="${fonts.family.serif}"
      export EMACS_UNICODE_FONT_FAMILY="${fonts.family.sansSerif}"
      export EMACS_EMOJI_FONT_FAMILY="${fonts.family.emoji}"
      export EMACS_TEXT_FONT_SIZE="${builtins.toString fonts.size.text}"
      export EMACS_UI_FONT_SIZE="${builtins.toString fonts.size.ui}"

      emacs --batch -Q \
        -l package \
        --eval '(setq package-quickstart t)' \
        -f package-quickstart-refresh
    '';
  };

  emacsd = trivialBuild {
    pname = "config";
    version = "dev";

    dontUnpack = true;

    installPhase = ''
      install -D -t $out ${init}/share/emacs/{native,site}-lisp/*
    '';
  };
in {
  options.modules.editors.emacs = {
    enable = mkEnableOption "emacs";
  };

  config = {
    services.emacs.enable = cfg.enable;
    services.emacs.package = emacs;
    services.emacs.install = true;

    user.xdg.configFile."emacs".source = emacsd;
  };
}
