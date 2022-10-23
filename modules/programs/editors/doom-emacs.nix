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

  baseEmacs = pkgs.emacsPgtkNativeComp.overrideAttrs (_old: {
    buildBuildInputs = [pkgs.gtk3];
  });

  doomEmacsConfigSource = config.dotfiles.configDir + "/doom-emacs";
  emacs =
    pkgs.runCommandLocal "doom-emacs" {
      buildInputs = with pkgs; [makeBinaryWrapper];
    } ''
      mkdir -p $out/bin

      for bin in $(find ${baseEmacs}/bin -not -name '.*' -a \( -type f -o -type l \) ); do
        ln -s $(realpath $bin) $out/bin/$(basename $bin)
        wrapProgram $out/bin/$(basename $bin) \
            --prefix PATH : "${makeBinPath editorPkgs}" \
            --set DOOMDIR ${doomEmacsConfigSource} \
            --set EMACSDIR "${config.user.home.dir}/.config/emacs" \
            --set EMACS_MONO_FONT_FAMILY "${fonts.family.monospace}" \
            --set EMACS_VARIABLE_PITCH_FONT_FAMILY "${fonts.family.sansSerif}" \
            --set EMACS_SERIF_FONT_FAMILY "${fonts.family.serif}" \
            --set EMACS_UNICODE_FONT_FAMILY "Latin Modern Math" \
            --set EMACS_TEXT_FONT_SIZE ${builtins.toString fonts.size.text} \
            --set EMACS_UI_FONT_SIZE ${builtins.toString fonts.size.ui}
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
      nodePackages.typescript-language-server
      terraform-ls
      bazel-buildtools
      rust-analyzer
      pyright
    ];

    user.packages = [doom emacs];
  };
}
