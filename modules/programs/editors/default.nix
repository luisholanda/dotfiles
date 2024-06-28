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
    (unstable.ollama.override {acceleration = "rocm";})

    # ASM
    asm-lsp

    # Bazel
    bazel-buildtools

    # C/C++
    ccls
    clang-tools_16
    unstable.cmake-language-server

    # Docker
    nodePackages.dockerfile-language-server-nodejs

    # Lua
    luajitPackages.luacheck
    sumneko-lua-language-server
    stylua

    # Markdown
    nodePackages.markdownlint-cli2
    proselint

    # Nix
    nil
    nixd
    alejandra

    # Protobuffer
    buf
    buf-language-server

    # Python
    black
    pylyzer
    python310Packages.isort

    # Shell
    shellcheck
    nodePackages.bash-language-server

    # Terraform
    terraform-ls

    # Typescript
    nodePackages.typescript

    # Rust
    rust-analyzer

    # YAML/JSON
    nodePackages.yaml-language-server
    nodePackages.vscode-json-languageserver

    # Zig
    zls

    # ShitHub Actions
    actionlint

    # DAP
    lldb_16
    llvmPackages_16.llvm
  ];

  config.user.xdg.configFile."zls.json".text = builtins.toJSON {
    warn_style = true;
    inlay_hints_hide_redundant_param_names = true;
    inlay_hints_hide_redundant_param_names_last_token = true;
    highlight_global_var_declarations = true;
    skip_std_references = true;
  };
}
