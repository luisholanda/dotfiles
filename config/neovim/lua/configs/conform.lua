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
	format_on_save = {
		lsp_format = "fallback",
		timeout = 500,
	},
}

vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

require("conform").setup(options)
