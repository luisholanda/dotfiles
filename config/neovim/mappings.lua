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
		["<leader>ra"] = {
			":IncRename ",
			"LSP Renaming",
		},
		["<leader>dd"] = {
			function()
				require("dapui").float_element()
			end,
			"Check element",
		},
		["<leader>dE"] = {
			function()
				require("dapui").eval(vim.fn.input("Expression: "))
			end,
			"Evaluate expression",
		},
	},
	v = {
		["<leader>ca"] = {
			function()
				vim.lsp.buf.code_action({ apply = true })
			end,
			"LSP Code Actions",
		},
		["<leader>de"] = {
			function()
				require("dapui").eval()
			end,
			"Evaluate selection",
		},
	},
}

M.git = {
	n = {
		["<leader>gg"] = { "<cmd>Neogit<cr>", "Open Neogit" },
	},
}

return M
