{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption;
  inherit (lib.my) addToPath;

  wrappedHelix = addToPath pkgs.helix config.modules.editors.extraPackages;
in {
  options.modules.editors.helix = {
    enable = mkEnableOption "helix";
  };

  config.user.home.programs.helix = {
    inherit (config.modules.editors.helix) enable;

    package = wrappedHelix;

    settings.editor = {
      cursorline = true;
      lsp = {
        display-messages = true;
        display-inlay-hints = false;
      };
      cursor-shape.insert = "bar";
    };

    languages.language-servers.rust-analyzer.config = {
      assist.emitMustUse = true;
      cargo.features = "all";
      check.command = "clippy";
      checkOnSave = true;
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
      linkedProjects = [];
      references.excludeImports = true;
    };
    languages.language-servers.yaml-language-server.config = {
      yaml.keyOrdering = false;
    };
    languages.language = [
      {
        name = "skylark";
        scope = "scope.python";
        file-types = ["bazel" "bzl" "BUILD" "WORKSPACE"];
        roots = [];
        comment-token = "#";
        indent = {
          tab-width = 4;
          unit = "    ";
        };
        grammar = "python";
      }
      {
        name = "python";
        language-servers = ["pylyzer"];
      }
    ];
  };
}
