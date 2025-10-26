local lint = require "lint"

lint.linters_by_ft = {
  lua = { "luacheck" },
  c = { "clangtidy" },
  cpp = { "clangtidy" },
  bzl = { "buildifier" },
  proto = { "protolint" },
  nix = { "deadnix" },
}

local autocmd_group = vim.api.nvim_create_augroup("NvimLintAutoCmds", {})

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  group = autocmd_group,
  callback = function()
    lint.try_lint()
  end,
})
