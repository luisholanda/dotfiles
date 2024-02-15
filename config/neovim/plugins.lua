local function get_hl_color(hl)
	return vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID(hl)), "fg", "gui")
end

---@type NvPluginSpec[]
local plugins = {
	-- LSP stuff.
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{
				"jose-elias-alvarez/null-ls.nvim",
				config = function()
					require("custom.configs.null-ls")
				end,
			},
			{
				"mrcjkb/haskell-tools.nvim",
				version = "^3", -- Recommended
				ft = { "haskell", "lhaskell", "cabal", "cabalproject" },
				config = function(_, _)
					vim.g.haskell_tools = {
						hls = {
							default_settings = {
								haskell = {
									cabalFormattingProvider = "cabal-fmt",
									formattingProvider = "ormolu",
									plugin = {
										cabalFmt = { globalOn = true },
										explicitFixity = { globalOn = true },
										hlint = { globalOn = true },
										ormolu = { globalOn = true },
									},
								},
							},
						},
					}
				end,
			},
			"simrat39/rust-tools.nvim",
			{
				"Saecki/crates.nvim",
				event = "BufRead Cargo.toml",
			},
			{
				"pmizio/typescript-tools.nvim",
				dependencies = { "nvim-lua/plenary.nvim" },
				opts = {
					settings = {
						tsserver_file_preferences = {
							quotePreference = "double",
							includeCompletionsForModuleExports = true,
							includeCompletionsForImportStatements = true,
							importModuleSpecifierEnding = "minimal",
							includeInlayParameterNameHints = "all",
							includeInlayParameterNameHintsWhenArgumentMatchesName = false,
							includeInlayFunctionParameterTypeHints = true,
							includeInlayVariableTypeHints = true,
							includeInlayPropertyDeclarationTypeHints = true,
							includeInlayFunctionLikeReturnTypeHints = true,
						},
					},
				},
			},
		},
		config = function()
			require("plugins.configs.lspconfig")
			require("custom.configs.lspconfig")
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter",
		opts = {
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "gti",
					node_incremental = "gtn",
					scope_incremental = "gts",
					node_decremental = "gtN",
				},
			},
			indent = {
				enable = true,
			},
		},
	},

	-- DAP stuff.
	{
		"mfussenegger/nvim-dap",
		config = function()
			require("custom.configs.nvim-dap")
		end,
		dependencies = {
			{ "LiadOz/nvim-dap-repl-highlights", config = true },
			"rcarriga/nvim-dap-ui",
		},
	},

	-- We install everything via Nix.
	{
		"williamboman/mason.nvim",
		enabled = false,
	},

	-- Long live magit
	{
		"TimUntersberger/neogit",
		cmd = "Neogit",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{
				"sindrets/diffview.nvim",
				opts = {
					enhanced_diff_hl = true,
				},
			},
		},
		opts = {
			disable_commit_confirmation = true,
			use_magit_keybindings = true,
			integrations = {
				diffview = true,
			},
		},
		config = function(_, opts)
			require("neogit").setup(opts)
		end,
	},

	-- UI stuff
	{
		"yorickpeterse/nvim-pqf",
		opts = {
			signs = {
				error = "",
				warning = "",
				info = "",
				hint = "",
			},
			show_multiple_lines = true,
		},
	},
	{
		"akinsho/git-conflict.nvim",
		config = true,
	},
	{
		"shellRaining/hlchunk.nvim",
		event = { "UIEnter" },
		opts = {
			blank = {
				enable = false,
			},
			chunk = {
				enable = false,
				chars = {
					horizontal_line = "─",
					vertical_line = "│",
					left_top = "╭",
					left_bottom = "╰",
					right_arrow = "─",
				},
			},
			indent = {
				enable = false,
				chars = { "│", "¦", "┆", "┊" },
				style = { get_hl_color("Whitespace") },
			},
			line_num = {
				enable = false,
				style = { get_hl_color("String") },
			},
		},
	},
	{
		"smjonas/inc-rename.nvim",
		cmd = "IncRename",
		config = true,
	},
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		dependencies = {
			"MunifTanjim/nui.nvim",
			"rcarriga/nvim-notify",
		},
		config = function()
			require("custom.configs.noice")
		end,
	},
}

return plugins
