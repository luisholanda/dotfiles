{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  inherit (lib.my) addToPath;

  wrappedHelix = addToPath pkgs.helix config.modules.editors.extraPackages;
in {
  options.modules.editors.helix = {
    enable = mkEnableOption "helix";
  };

  config.user.sessionVariables.EDITOR = mkIf config.modules.editors.helix.enable "hx";

  config.user.home.programs.helix = {
    inherit (config.modules.editors.helix) enable;

    package = wrappedHelix;

    settings.editor = {
      auto-save = true;
      cursorline = true;
      lsp = {
        display-messages = true;
        display-inlay-hints = false;
      };
      cursor-shape.insert = "bar";
      line-number = "relative";
      completion-timeout = 5;
      completion-replace = false;
      color-modes = true;
      popup-border = "popup";
    };

    languages.language-server.rust-analyzer.config = {
      assist.emitMustUse = true;
      cargo.features = "all";
      check.command = "clippy";
      checkOnSave = true;
      completion = {
        limit = 20;
        termSearch.enable = true;
      };
      imports.prefix = "crate";
      inlayHints = {
        expressionAdjustmentHints = {
          enable = "always";
          hideOutsideUnsafe = true;
        };
        lifetimeElisionHints.useParameterNames = true;
        typeHints.hideNamedConstructor = true;
      };
      lens = {
        references = {
          adt.enable = true;
          method.enable = true;
          trait.enable = true;
        };
        run.enable = false;
      };
      references.excludeImports = true;
    };
    languages.language-server.yaml-language-server.config = {
      yaml.keyOrdering = false;
    };
    languages.language = [
      {
        name = "python";
        language-servers = ["pylyzer"];
      }
      {
        name = "rust";
        language-servers = ["rust-analyzer"];
      }
    ];
  };
}
