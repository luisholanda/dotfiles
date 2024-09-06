-- EXAMPLE
local capabilities = require("nvchad.configs.lspconfig").capabilities

local lspconfig = require("lspconfig")

local autocmd_group = vim.api.nvim_create_augroup("LspCustomAutoCmds", { clear = true })

local function on_attach(client, bufnr)
	vim.api.nvim_create_autocmd("CursorHold", {
		buffer = bufnr,
		group = autocmd_group,
		callback = function()
			vim.diagnostic.open_float(nil, {
				focusable = false,
				close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
				border = "rounded",
				source = "always",
				prefix = " ",
				scope = "cursor",
			})
		end,
	})

	if client.server_capabilities.documentFormattingProvider then
		vim.api.nvim_create_autocmd("InsertLeave", {
			buffer = bufnr,
			group = autocmd_group,
			callback = function()
				vim.lsp.buf.format()
			end,
		})
	end
end

local servers = {
	clangd = {
		filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
	},
	cmake = {},
	dockerls = {},
  hls = {},
	nil_ls = {},
	basedpyright = {},
	terraformls = {},
	yamlls = {
		settings = {
			yaml = {
				keyOrdering = false,
			},
		},
	},
	zls = {},
	rust_analyzer = {
		settings = {
			["rust-analyzer"] = {
				assist = {
					emitMustUse = true,
				},
				cargo = {
					features = "all",
				},
				check = {
					command = "clippy",
				},
				checkOnSave = true,
				imports = {
					prefix = "crate",
				},
				inlayHints = {
					expressionAdjustmentHints = {
						enable = "always",
						hideOutsideUnsafe = true,
					},
					lifetimeElisionHints = {
						enable = "skip_trivial",
					},
					typeHints = {
						hideClsoureInitialization = true,
						hideNamedConstructor = true,
					},
				},
				lens = {
					references = {
						adt = { enable = true },
						method = { enable = true },
						trait = { enable = true },
					},
					run = { enable = false },
				},
			},
		},
	},
}

-- lsps with default config
for server, config in pairs(servers) do
	lspconfig[server].setup(vim.tbl_deep_extend("force", config, {
		on_attach = on_attach,
		capabilities = capabilities,
	}))
end
