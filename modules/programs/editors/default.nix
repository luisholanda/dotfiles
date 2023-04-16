{
  lib,
  pkgs,
  ...
}: let
  inherit (lib.my) mkPkgsOpt;
in {
  options.modules.editors = {
    extraPackages = mkPkgsOpt "only editors to see.";
  };

  config.modules.editors.extraPackages = with pkgs; [
    # General
    git
    (ripgrep.override {withPCRE2 = true;})

    # Bazel
    bazel-buildtools

    # C/C++
    clang-tools_15

    # Docker
    nodePackages.dockerfile-language-server-nodejs

    # Lua
    sumneko-lua-language-server
    stylua

    # Markdown
    nodePackages.markdownlint-cli2
    proselint

    # Nix
    nil

    # Protobuffer
    buf
    buf-language-server

    # Python
    black
    nodePackages.pyright
    python310Packages.isort

    # Shell
    shellcheck
    nodePackages.bash-language-server

    # Terraform
    terraform-ls

    # Typescript
    nodePackages.typescript
    nodePackages.typescript-language-server

    # Rust
    rust-analyzer
    rustfmt

    # YAML/JSON
    nodePackages.yaml-language-server
    nodePackages.vscode-json-languageserver
  ];
}
