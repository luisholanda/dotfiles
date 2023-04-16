---@type ChadrcConfig
local M = {}

M.ui = {
	theme = "chadracula",
	lsp_semantic_tokens = true,

	cmp = {
		lspkind_text = false,
		style = "atom_colored",
	},

	telescope = { style = "bordered" },

	nvdash = { load_on_startup = true },

	hl_override = {
		Comment = {
			italic = true,
		},
	},
}

M.plugins = "custom.plugins"

M.mappings = {
	general = {
		n = {
			["<leader>sh"] = { "<cmd>split<CR>", "new horizontal split" },
			["<leader>sv"] = { "<cmd>vsplit<CR>", "new vertical split" },
		},
	},
}

return M
