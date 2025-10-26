---@type conform.setupOpts
local options = {
  formatters_by_ft = {
    bash = { "shfmt" },
    bzl = { "buildifier" },
    c = { "clang-format" },
    cpp = { "clang-format" },
    go = { "gofumpt", "goimports" },
    lua = { "stylua" },
    nix = { "alejandra" },
    proto = { "buf" },
    python = { "ruff_fix", "ruff_organize_imports", "ruff_format" },
    rust = { "rustfmt" },
    sh = { "shfmt" },
    ["*"] = { "trim_newlines", "trim_whitespace" },
  },
  format_on_save = {},
  default_format_opts = {
    lsp_format = "first",
    timeout = 500,
  },
}

vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

local conform = require "conform"
local augroup = vim.api.nvim_create_augroup("ConformGroup", { clear = true })

vim.api.nvim_create_autocmd("InsertLeave", {
  group = augroup,
  callback = function(args)
    conform.format({ bufnr = args.buf, async = true }, nil)
  end,
})

conform.setup(options)
