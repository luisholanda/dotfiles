--- @type DefaultMappingsTable
local M = {}

M.general = {
	n = {
		["<leader>sh"] = { "<cmd>split<CR>", "new horizontal split" },
		["<leader>sv"] = { "<cmd>vsplit<CR>", "new vertical split" },
	},
}

M.lsp = {
	n = {
		["<leader>ca"] = {
			function()
				vim.lsp.buf.code_action({ apply = true })
			end,
			"LSP Code Actions",
		},
	},
	v = {

		["<leader>ca"] = {
			function()
				vim.lsp.buf.code_action({ apply = true })
			end,
			"LSP Code Actions",
		},
	},
}

M.git = {
	n = {
		["<leader>gg"] = { "<cmd>Neogit<cr>", "Open Neogit" },
	},
}

return M
