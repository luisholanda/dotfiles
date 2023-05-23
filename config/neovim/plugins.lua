---@type NvPluginSpec[]
local plugins = {
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{
				"jose-elias-alvarez/null-ls.nvim",
				config = function()
					require("custom.configs.null-ls")
				end,
			},
			"simrat39/rust-tools.nvim",
			{
				"Saecki/crates.nvim",
				event = "BufRead Cargo.toml",
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
}

return plugins
