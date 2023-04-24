local nvchad_on_attach = require("plugins.configs.lspconfig").on_attach
local capabilities = require("plugins.configs.lspconfig").capabilities

local lspconfig = require("lspconfig")

local function on_attach(client, bufnr)
	local document_formatting_provider = client.server_capabilities.documentFormattingProvider
	local document_range_formatting_provider = client.server_capabilities.documentRangeFormattingProvider

	nvchad_on_attach(client, bufnr)

	client.server_capabilities.documentFormattingProvider = document_formatting_provider
	client.server_capabilities.documentRangeFormattingProvider = document_range_formatting_provider
end

local servers = {
	bufls = {},
	clangd = {
		filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
	},
	dockerls = {},
	nil_ls = {},
	pyright = {},
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
	terraformls = {},
	tsserver = {},
	yamlls = {},
	zls = {},
}

for server, config in pairs(servers) do
	lspconfig[server].setup(vim.tbl_deep_extend("force", config, {
		on_attach = on_attach,
		capabilities = capabilities,
	}))
end
