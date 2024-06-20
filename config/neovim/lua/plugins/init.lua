--@type LazyPluginSpec[]
return {
	{
		"hrsh7th/nvim-cmp",
		opts = function()
			local opts = require("nvchad.configs.cmp")
			opts.formatting.fields = { "kind", "abbr" }
			opts.view = { enable = "native" }
			table.insert(opts.sources, { name = "codeium" })
			return opts
		end,
		config = function(_, opts)
			local cmp = require("cmp")
			cmp.setup(opts)

			cmp.setup.cmdline({ "/", "?" }, {
				mapping = cmp.mapping.preset.cmdline(),
				preselect = "item",
				sources = {
					{ name = "buffer" },
				},
				view = {
					enable = { name = "wildmenu", separator = "|" },
				},
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		config = function()
			require("nvchad.configs.lspconfig").defaults()
			require("configs.lspconfig")
		end,
	},
	{
		"icholy/lsplinks.nvim",
		dependencies = { "neovim/nvim-lspconfig" },
	},
	{
		"saecki/crates.nvim",
		event = { "BufRead Cargo.toml" },
		dependencies = { "neovim/nvim-lspconfig" },
	},
	{
		"nvim-treesitter/nvim-treesitter",
		opts = {
			incremental_selection = {
				enable = false,
			},
			indent = {
				enable = true,
			},
		},
	},
	"yorickpeterse/nvim-pqf",
	{
		"https://git.sr.ht/~whynothugo/lsp_lines.nvim",
		config = function()
			vim.diagnostic.config({
				virtual_text = false,
				virtual_lines = {
					highlight_whole_line = false,
				},
			})
		end,
	},
	{
		"m4xshen/smartcolumn.nvim",
		opts = {
			colorcolumn = { "88", "100" },
		},
	},
	{
		"NeogitOrg/neogit",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim",
		},
		opts = {
			graph_style = "unicode",
		},
	},
	{
		"Exafunction/codeium.nvim",
		enable = true,
		opts = {
			enable_local_search = true,
			enable_index_service = true,
			tools = {
				language_server = "codeium",
			},
		},
	},

	-- Disabled built-in stuff.
	{
		"nvim-tree/nvim-tree.lua",
		enable = false,
	},
	{
		"williamboman/mason.nvim",
		enable = false,
	},
}
