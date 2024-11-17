local lint = require("lint")

lint.linters_by_ft = {
	lua = { "luacheck" },
	c = { "clangtidy" },
	cpp = { "clangtidy" },
}

local autocmd_group = vim.api.nvim_create_augroup("NvimLintAutoCmds", {})

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
	pattern = { "*.lua", "*.c", "*.h", "*.cc", "*.cpp", "*.cxx", "*.hh", "*.hpp", "*.hxx" },
	group = autocmd_group,
	callback = function()
		lint.try_lint()
	end,
})
