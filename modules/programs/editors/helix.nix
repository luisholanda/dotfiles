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

  #config.user.sessionVariables.EDITOR = mkIf config.modules.editors.helix.enable "hx";

  config.user.home.programs.helix = {
    inherit (config.modules.editors.helix) enable;

    package = wrappedHelix;

    settings.editor = {
      auto-save = {
        focus-lost = true;
        after-delay = {
          enable = true;
        };
      };
      cursorline = true;
      lsp = {
        display-messages = true;
        display-inlay-hints = true;
      };
      cursor-shape.insert = "underline";
      line-number = "relative";
      completion-timeout = 5;
      completion-replace = false;
      color-modes = true;
      popup-border = "popup";
      inline-diagnostics = {
        cursor-line = "warning";
        other-lines = "hint";
        max-diagnostics = 3;
      };
      rulers = [
        88
        120
      ];
      statusline = {
        left = [
          "mode"
          "spacer"
          "spinner"
          "file-name"
          "separator"
          "spacer"
          "version-control"
        ];
        right = [
          "diagnostics"
          "position"
        ];
        separator = "│";
        diagnostics = [
          "warning"
          "error"
          "info"
        ];
        workspace-diagnostics = [
          "warning"
          "error"
        ];
      };
    };

    languages.language-server.capnprotols = {
      command = "capnprotols";
    };
    languages.language-server.gopls.config = {
      gofumpt = true;
      semanticTokens = true;
      staticcheck = true;
      analyses = {
        loopclosure = false;
        shadow = true;
      };
      hints = {
        assignVariableType = true;
        constantValues = true;
        parameterNames = true;
      };
    };
    languages.language-server.rust-analyzer.config = {
      assist.emitMustUse = true;
      cargo.features = "all";
      check.command = "clippy";
      checkOnSave = true;
      inlayHints = {
        expressionAdjustmentHints = {
          enable = "always";
          hideOutsideUnsafe = true;
        };
        lifetimeElisionHints = {
          enable = "skip_trivial";
          useParameterNames = true;
        };
        typeHints = {
          hideClosureInitialization = true;
          hideNamedConstructor = true;
        };
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
    languages.language-server.starpls = {
      args = [
        "server"
        "--experimental_enable_label_completions"
        "--experimental_infer_ctx_attributes"
      ];
    };
    languages.language-server.typos-lsp = {
      command = "typos-lsp";
    };
    languages.language-server.yaml-language-server.config = {
      yaml.keyOrdering = false;
    };
    languages.language = [
      {
        name = "go";
        language-servers = [
          "gopls"
          "golangci-lint-langserver"
          {
            name = "typos-lsp";
            only-features = [
              "code-action"
              "diagnostics"
            ];
          }
        ];
      }
      {
        name = "python";
        language-servers = [
          "ruff"
          {
            name = "typos-lsp";
            only-features = [
              "code-action"
              "diagnostics"
            ];
          }
        ];
      }
      {
        name = "rust";
        language-servers = [
          "rust-analyzer"
          {
            name = "typos-lsp";
            only-features = [
              "code-action"
              "diagnostics"
            ];
          }
        ];
      }
      {
        name = "nix";
        auto-format = true;
        formatter.command = "${pkgs.alejandra}/bin/alejandra";
      }
      {
        name = "flatbuffers";
        scope = "source.flatbuffers";
        file-types = ["fbs"];
        roots = [];
        comment-token = "//";
      }
      {
        name = "capnp";
        language-servers = ["capnprotols"];
      }
    ];
    languages.grammar = [
      {
        name = "flatbuffers";
        source.git = "https://github.com/demfabris/tree-sitter-flatbuffers";
        source.rev = "main";
      }
    ];
  };
}
