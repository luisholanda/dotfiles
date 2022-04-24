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

    languages = [
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
        language-server = {
          command = "pyright-langserver";
          args = ["--stdio"];
        };
      }
    ];
  };
}
