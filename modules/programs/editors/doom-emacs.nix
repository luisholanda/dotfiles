{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf makeBinPath;
  inherit (pkgs.stdenv) isDarwin;
  inherit (config.stylix) fonts;

  emacsCfg = config.modules.editors.emacs;
  editorPkgs = config.modules.editors.extraPackages;

  baseEmacs =
    if isDarwin
    then pkgs.emacs-macport
    else
      pkgs.emacs-pgtk.overrideAttrs (_old: {
        buildBuildInputs = [pkgs.gtk3];
      });

  emacs =
    pkgs.runCommandLocal "doom-emacs"
    {
      buildInputs = with pkgs; [makeBinaryWrapper];
    }
    ''
      mkdir -p $out/bin

      for bin in $(find ${baseEmacs}/bin -not -name '.*' -a \( -type f -o -type l \) ); do
        ln -s $(realpath $bin) $out/bin/$(basename $bin)
        wrapProgram $out/bin/$(basename $bin) \
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
    modules.editors.extraPackages = with pkgs; [
      ## Emacs dependencies
      binutils # native-comp needs 'as'
      emacs-all-the-icons-fonts

      ## Doom dependencies
      gnutls
      fd
      imagemagick
      pinentry-emacs
      zstd

      ## Module dependencies
      # :checkers spell
      (aspellWithDicts (
        ds:
          with ds; [
            en
            en-computers
            en-science
            pt_BR
          ]
      ))

      # :checkers grammar
      languagetool

      # :lang beancount
      beancount-language-server
      beancount

      # :lang cc
      rtags

      # :lang markdown
      discount

      # :lang web
      html-tidy
      nodePackages.stylelint

      # :tool docker
      dockerfile-language-server
    ];

    user.packages = mkIf (!isDarwin) [
      doom
      baseEmacs
    ];

    user.xdg.configFile.doom.source = "${config.dotfiles.dir}/config/doom-emacs";
    user.xdg.configFile.doom.recursive = true;
    user.sessionVariables.EMACS_PATH_PREFIX = makeBinPath editorPkgs;

    environment.systemPackages = mkIf isDarwin [
      doom
      baseEmacs
    ];
  };
}
