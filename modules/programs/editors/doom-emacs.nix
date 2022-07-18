{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf makeBinPath;
  inherit (lib.my) wrapProgram;
  inherit (config.theme) fonts;
  inherit (inputs) doom-emacs;

  emacsCfg = config.modules.editors.emacs;
  editorPkgs = config.modules.editors.extraPackages;

  baseEmacs = pkgs.emacsPgtkNativeComp;

  doomEmacsConfigSource = config.dotfiles.configDir + "/doom-emacs";
  emacs = wrapProgram baseEmacs {
    prefix.PATH = makeBinPath editorPkgs;
    set = with fonts.family; {
      DOOMDIR = doomEmacsConfigSource;
      EMACSDIR = "${config.user.home.dir}/.config/emacs";
      EMACS_MONO_FONT_FAMILY = monospace;
      EMACS_VARIABLE_PITCH_FONT_FAMILY = sansSerif;
      EMACS_SERIF_FONT_FAMILY = serif;
      EMACS_UNICODE_FONT_FAMILY = "Latin Modern Math";
      EMACS_TEXT_FONT_SIZE = fonts.size.text;
      EMACS_UI_FONT_SIZE = fonts.size.ui;
    };
  };

  doom = pkgs.writeScriptBin "doom" ''
    #!${pkgs.stdenv.shell}
    exec ~/.config/emacs/bin/doom $@
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
      clang-tools_14

      # :lang coq
      lmmath

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

      # :lang zig
      zls

      nodePackages.yaml-language-server
      nodePackages.bash-language-server
      nodePackages.vscode-json-languageserver
      nodePackages.typescript
      terraform-ls
      bazel-buildtools
    ];

    user.packages = [doom emacs];
  };
}
