--@type conform.setupOpts
local options = {
	formatters_by_ft = {
		bash = { "shfmt" },
		bzl = { "buildifier" },
		c = { "clang-format" },
		cpp = { "clang-format" },
		lua = { "stylua" },
		nix = { "alejandra" },
		proto = { "buf" },
		python = { "docstrfmt", "ruff_format", "ruff_fix" },
		rust = { "rustfmt" },
		sh = { "shfmt" },
	},
}

require("conform").setup(options)
