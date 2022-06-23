{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf makeBinPath;
  inherit (lib.my) wrapProgram;
  inherit (config.theme) fonts;

  emacsCfg = config.modules.editors.emacs;
  editorPkgs = config.modules.editors.extraPackages;

  baseEmacs = pkgs.emacsPgtkGcc or pkgs.emacsPgtkNativeComp;

  doomEmacsConfigSource = config.dotfiles.configDir + "/doom-emacs";
  doomEmacs = wrapProgram baseEmacs {
    prefix.PATH = makeBinPath editorPkgs;
    set = with fonts.family; {
      DOOMDIR = doomEmacsConfigSource;
      EMACSDIR = "~/.config/emacs";
      EMACS_MONO_FONT_FAMILY = monospace;
      EMACS_VARIABLE_PITCH_FONT_FAMILY = sansSerif;
      EMACS_SERIF_FONT_FAMILY = serif;
      EMACS_UNICODE_FONT_FAMILY = sansSerif;
      EMACS_TEXT_FONT_SIZE = fonts.size.text;
      EMACS_UI_FONT_SIZE = fonts.size.ui;
    };
  };

  doom = pkgs.writeScriptBin "doom" ''    #
       exec ~/.config/emacs/bin/doom $@
  '';

  emacs = pkgs.writeScriptBin "emacs" ''
    version=$(emacseditor --version | cut -d' ' -f2)
    exec ${doomEmacs}/bin/emacs-$version $@
  '';
in {
  options.modules.editors.emacs.doom.enable = mkEnableOption "doom-emacs";

  config = mkIf emacsCfg.doom.enable {
    assertions = [
      {
        assertion = !emacsCfg.enable;
        message = "Doom Emacs cannot be enable together with base emacs! Choose only one.";
      }
    ];

    modules.editors.extraPackages = with pkgs; [
      ## Emacs dependencies
      binutils # native-comp needs 'as'
      emacs-all-the-icons-fonts

      ## Doom dependencies
      git
      (ripgrep.override {withPCRE2 = true;})
      gnutls
      fd
      imagemagick
      pinentry_emacs
      zstd

      ## Module dependencies
      # :checkers spell
      (aspellWithDicts (ds:
        with ds; [
          en
          en-computers
          en-science
          pt_BR
        ]))

      # :checkers grammar
      languagetool

      # :lang cc
      rtags

      # :lang markdown
      nodePackages.markdownlint-cli2
      proselint
      discount

      # :lang sh
      shellcheck

      # :lang python
      black
      python39Packages.isort

      # :lang web
      html-tidy
      nodePackages.stylelint

      nodePackages.yaml-language-server
      nodePackages.bash-language-server
      nodePackages.vscode-json-languageserver
      terraform-ls
      bazel-buildtools
    ];

    services.emacs.enable = true;
    services.emacs.package = doomEmacs;
    services.emacs.install = true;

    user.packages = [doom emacs];
  };
}
