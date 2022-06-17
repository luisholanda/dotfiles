local nvim_lsp = nil
local lsp_status = nil
local lsputil = nil

local M = {}

function M.update_completion_kinds()
	vim.lsp.protocol.CompletionItemKind = {
		"",
		"ƒ",
		"",
		"",
		"",
		"",
		"ﰮ",
		"",
		"",
		"",
		"",
		"了",
		"",
		"﬌",
		"",
		"",
		"",
		"",
		"",
		"",
	}
end

local function lsp_on_attach(client, bufnr)
	vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

	if client.config.flags then
		client.config.flags.allow_incremental_sync = true
	end

	lsp_status.on_attach(client)
end

local function get_capabilities()
	local capabilities = vim.lsp.protocol.make_client_capabilities()
	capabilities.textDocument.completion.completionItem.snippetSupport = true
	capabilities = vim.tbl_extend("keep", capabilities, lsp_status.capabilities)

	return capabilities
end

local function configure_servers()
	local capabilities = get_capabilities()

	local setup = function(server, config)
		server.setup(vim.tbl_extend("force", config or {}, {
			capabilities = capabilities,
			on_attach = lsp_on_attach,
		}))
	end

	vim.lsp.set_log_level(vim.lsp.log_levels.DEBUG)
	setup(nvim_lsp.rust_analyzer, {
		root_dir = nvim_lsp.util.root_pattern("Cargo.lock", "rust-project.json"),
		cmd = { "rust-analyzer" },
		init_options = {
			cargo = { features = "all", loadOutDirsFromCheck = true, runBuildScripts = true },
			checkOnSave = { features = "all" },
			completion = { addCallArgumentSnippets = true, postfix = { enable = true } },
			procMacro = { enable = true },
		},
	})

	setup(nvim_lsp.ccls)
	setup(nvim_lsp.cmake)
	setup(nvim_lsp.sumneko_lua, {
		-- Assumes installed via nixpkgs, it already takes care of passing main.lua path.
		cmd = { vim.fn.exepath("lua-language-server") },
		settings = {
			Lua = {
				runtime = {
					version = "LuaJIT",
					path = (function()
						local path = vim.split(package.path, ";")
						table.insert(path, "lua/?.lua")
						table.insert(path, "lua/?/init.lua")
						return path
					end)(),
				},
				diagnostics = { globals = { "vim" } },
				workspace = { library = vim.api.nvim_get_runtime_file("", true) },
				telemetry = { enable = false },
			},
		},
	})
	setup(nvim_lsp.vimls)
	setup(nvim_lsp.pyright, {
		root_dir = nvim_lsp.util.root_pattern(".git"),
		settings = {
			python = {
				analysis = { autoSearchPaths = true, useLibraryCodeForTypes = true },
				pythonPath = vim.fn.exepath("python"),
				venvPath = "/Users/luiscm/.pyenv/versions",
			},
		},
	})
	setup(nvim_lsp.terraformls)
	setup(nvim_lsp.tsserver)
	setup(nvim_lsp.rnix)
	setup(nvim_lsp.texlab, {
		root_dir = nvim_lsp.util.root_pattern(".git", "shell.nix"),
		settings = {
			texlab = {
				rootDirectory = vim.fn.getcwd(),
				build = {
					args = {
						"-pdf",
						"-shell-escape",
						"-synctex=1",
						"-output-directory=latex.out",
						"-interaction=nonstopmode",
						"%f",
					},
					forwardSearchAfter = true,
					onSave = true,
					outputDirectory = "latex.out",
				},
				forwardSearch = {
					executable = "zathura",
					args = { "--synctex-forward", "%l:1:%f", "%p" },
					onSave = true,
				},
			},
		},
	})
	setup(nvim_lsp.vuels, {
		cmd = { vim.fn.exepath("vls") },
		init_options = {
			vetur = {
				completion = { autoImport = true },
				useWorkspaceDependencies = true,
			},
		},
	})
end

local function setup_callbacks()
	vim.lsp.handlers["textDocument/codeAction"] = lsputil.codeAction.code_action_handler
	vim.lsp.handlers["textDocument/references"] = lsputil.locations.references_handler
	vim.lsp.handlers["textDocument/definition"] = lsputil.locations.definition_handler
	vim.lsp.handlers["textDocument/declaration"] = lsputil.locations.declaration_handler
	vim.lsp.handlers["textDocument/typeDefinition"] = lsputil.locations.typeDefinition_handler
	vim.lsp.handlers["textDocument/implementation"] = lsputil.locations.implementation_handler
	vim.lsp.handlers["textDocument/documentSymbol"] = lsputil.locations.document_handler
	vim.lsp.handlers["workspace/symbol"] = lsputil.symbols.workspace_handler
	vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
		signs = true,
		virtual_text = true,
		underline = true,
		update_in_insert = false,
	})
end

function M.setup()
	nvim_lsp = require("lspconfig")
	lsp_status = require("lsp-status")
	lsputil = {
		codeAction = require("lsputil.codeAction"),
		locations = require("lsputil.locations"),
		symbols = require("lsputil.symbols"),
	}

	M.update_completion_kinds()

	lsp_status.config({
		current_function = false,
		diagnostics = false,
		spinner_frames = { "⣾", "⣽", "⣻", "⢿", "⡿", "⣟", "⣯", "⣷" },
	})
	lsp_status.register_progress()

	setup_callbacks()
	configure_servers()
end

return M
