local nvchad_on_attach = require("plugins.configs.lspconfig").on_attach
local capabilities = require("plugins.configs.lspconfig").capabilities

local lspconfig = require("lspconfig")
local rust_tools = require("rust-tools")
local util = require("lspconfig.util")

local function on_attach(client, bufnr)
	local document_formatting_provider = client.server_capabilities.documentFormattingProvider
	local document_range_formatting_provider = client.server_capabilities.documentRangeFormattingProvider

	nvchad_on_attach(client, bufnr)

	client.server_capabilities.documentFormattingProvider = document_formatting_provider
	client.server_capabilities.documentRangeFormattingProvider = document_range_formatting_provider

	local group = vim.api.nvim_create_augroup("LspCustomAutoCmds", { clear = true })

	vim.api.nvim_create_autocmd("CursorHold", {
		buffer = bufnr,
		group = group,
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

	if client.server_capabilities.documentFormattingProvider or client.name == "null-ls" then
		vim.api.nvim_create_autocmd("InsertLeave", {
			buffer = bufnr,
			group = group,
			callback = function()
				vim.lsp.buf.format()
			end,
		})
	end
end

local servers = {
	bufls = {},
	clangd = {
		filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
	},
	dockerls = {},
	nil_ls = {},
	pyright = {},
	terraformls = {},
	yamlls = {
		settings = {
			yaml = {
				keyOrdering = false,
			},
		},
	},
	zls = {},
}

for server, config in pairs(servers) do
	lspconfig[server].setup(vim.tbl_deep_extend("force", config, {
		on_attach = on_attach,
		capabilities = capabilities,
	}))
end

rust_tools.setup({
	tools = {
		inlay_hints = {
			parameter_hints_prefix = "🠈",
			other_hints_prefix = "🡆",
		},
	},
	dap = { adapter = nil },
	server = {
		standalone = false,
		on_attach = on_attach,
		on_init = function(client)
			local path = client.workspace_folders[1].name

			if path == vim.fn.expand("~/Projects/pl") then
				client.config.settings["rust-analyzer"].check.overrideCommand = { "rust-analyzer-check" }
				client.config.settings["rust-analyzer"].linkedProjects = { string.format("%s/rust-project.json", path) }
			end

			client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
			return true
		end,
		root_dir = function(fname)
			return util.root_pattern("rust-project.json")(fname)
				or util.root_pattern("Cargo.toml")(fname)
				or util.find_git_ancestor(fname)
		end,
		capabilities = capabilities,
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
				linkedProjects = {},
			},
		},
	},
})
