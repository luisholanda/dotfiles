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
    fd

    # ASM
    #asm-lsp

    # Bazel
    bazel-buildtools
    unstable.starpls

    # Docker
    dockerfile-language-server-nodejs

    # Go
    golangci-lint-langserver
    golangci-lint
    gopls
    gofumpt
    gotools

    # Lua
    luajitPackages.luacheck
    sumneko-lua-language-server
    stylua

    # Markdown
    markdownlint-cli2
    proselint

    # Nix
    nil
    nixd
    alejandra

    # Protobuffer
    buf

    # Python
    #unstable.basedpyright
    unstable.pyright
    ruff

    # Shell
    shellcheck
    shfmt
    bash-language-server

    # Terraform
    terraform-ls

    # Rust
    unstable.rust-analyzer

    # YAML/JSON
    yaml-language-server

    # Zig
    #zls

    # ShitHub Actions
    actionlint

    # DAP
    lldb_19
    llvmPackages_19.llvm
  ];

  config.user.xdg.configFile."zls.json".text = builtins.toJSON {
    enable_build_on_save = true;
    build_on_save_step = "check";
    warn_style = true;
    inlay_hints_hide_redundant_param_names = true;
    inlay_hints_hide_redundant_param_names_last_token = true;
    highlight_global_var_declarations = true;
    skip_std_references = true;
  };
}
