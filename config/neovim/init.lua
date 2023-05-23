local hl_overrides = {
	["@lsp.mod.mutable"] = {
		underline = true,
	},
	["@lsp.mod.reference"] = {
		italic = true,
	},
	["@lsp.type.comment"] = {},

	-- Comment tokens
	["@text.note"] = {
		link = "DiagnosticInfo",
	},
	["@text.danger"] = {
		link = "DiagnosticError",
	},
	["@text.warning"] = {
		link = "DiagnosticWarn",
	},
}

local group = vim.api.nvim_create_augroup("UserAutoCmds", { clear = true })

vim.api.nvim_create_autocmd("BufEnter", {
	desc = "Set custom highlight overrides",
	group = group,
	callback = function()
		for hl, value in pairs(hl_overrides) do
			vim.api.nvim_set_hl(0, hl, value)
		end
	end,
})

vim.api.nvim_create_autocmd("BufEnter", {
	desc = "Consider all .tf files as terraform files",
	group = group,
	pattern = { "*.tf" },
	command = "set filetype=terraform",
})
