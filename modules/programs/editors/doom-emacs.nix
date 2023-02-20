{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf makeBinPath;
  inherit (config.theme) fonts;

  emacsCfg = config.modules.editors.emacs;
  editorPkgs = config.modules.editors.extraPackages;

  baseEmacs = pkgs.emacsPgtk.overrideAttrs (_old: {
    buildBuildInputs = [pkgs.gtk3];
  });

  emacs =
    pkgs.runCommandLocal "doom-emacs" {
      buildInputs = with pkgs; [makeBinaryWrapper];
    } ''
      mkdir -p $out/bin

      for bin in $(find ${baseEmacs}/bin -not -name '.*' -a \( -type f -o -type l \) ); do
        ln -s $(realpath $bin) $out/bin/$(basename $bin)
        wrapProgram $out/bin/$(basename $bin) \
            --prefix PATH : "${makeBinPath editorPkgs}" \
            --set DOOMDIR "~/.dotfiles/config/doom-emacs" \
            --set EMACSDIR "${config.user.home.dir}/.config/emacs" \
            --set EMACS_MONO_FONT_FAMILY "${fonts.family.monospace}" \
            --set EMACS_VARIABLE_PITCH_FONT_FAMILY "${fonts.family.sansSerif}" \
            --set EMACS_SERIF_FONT_FAMILY "${fonts.family.serif}" \
            --set EMACS_UNICODE_FONT_FAMILY "Latin Modern Math" \
            --set EMACS_TEXT_FONT_SIZE ${builtins.toString fonts.size.text} \
            --set EMACS_UI_FONT_SIZE ${builtins.toString fonts.size.ui} \
            --set LSP_USE_PLISTS true
      done

      ln -s ${baseEmacs}/lib/emacs/*/native-lisp $out/native-lisp
    '';

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
      pinentry-emacs
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

      # :lang beancount
      beancount-language-server
      beancount

      # :lang cc
      rtags
      clang-tools_14

      # :lang coq
      lmmath

      # :lang markdown
      nodePackages.markdownlint-cli2
      proselint
      discount

      # :lang nix
      rnix-lsp

      # :lang sh
      shellcheck
      nodePackages.bash-language-server

      # :lang python
      black
      python39Packages.isort

      # :lang web
      html-tidy
      nodePackages.stylelint

      # :tool tree-sitter
      tree-sitter
      nodejs

      # :tool terraform
      terraform-ls

      nodePackages.yaml-language-server
      nodePackages.vscode-json-languageserver
      nodePackages.typescript
      nodePackages.typescript-language-server
      bazel-buildtools
      rust-analyzer
      rustfmt
      pyright
    ];

    user.packages = [doom emacs];
  };
}
