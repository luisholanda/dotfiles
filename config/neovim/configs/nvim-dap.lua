local dap = require("dap")
local dapui = require("dapui")
local dap_utils = require("dap.utils")

local function ask_cwd_or_default(default)
	local anwser = vim.fn.input("CWD for the binary: ", vim.fn.getcwd() .. "/")
	if anwser == "" then
		anwser = nil
	end

	return anwser or default
end

local function ask_program()
	return vim.fn.input("Path to binary: ", vim.fn.getcwd() .. "/")
end

local function get_rust_types()
	-- Find out where to look for the pretty printer Python module
	local rustc_sysroot = vim.fn.trim(vim.fn.system("cargo rustc --print sysroot"))

	local script_import = 'command script import "' .. rustc_sysroot .. '/lib/rustlib/etc/lldb_lookup.py"'
	local commands_file = rustc_sysroot .. "/lib/rustlib/etc/lldb_commands"

	local commands = {}
	local file = io.open(commands_file, "r")
	if file then
		for line in file:lines() do
			table.insert(commands, line)
		end
		file:close()
	end
	table.insert(commands, 1, script_import)

	return commands
end

local function make_clike_dap_configs(filetype)
	return {

		{
			name = "Launch binary",
			type = "lldb",
			request = "launch",
			program = ask_program,
			cwd = function()
				return ask_cwd_or_default("${workspaceFolder}")
			end,
			stopOnEntry = true,
			repl_lang = filetype,
		},
		{
			name = "Attach binary",
			type = "lldb",
			request = "attach",
			pid = dap_utils.pick_process,
			stopOnEntry = true,
			repl_lang = filetype,
		},
	}
end

dap.adapters.lldb = {
	type = "executable",
	command = vim.fn.exepath("lldb-vscode"),
	name = "lldb",
}

dap.configurations.cpp = make_clike_dap_configs("cpp")
dap.configurations.c = make_clike_dap_configs("c")
dap.configurations.zig = make_clike_dap_configs("zig")
dap.configurations.rust = {
	{
		name = "Launch target",
		type = "lldb",
		request = "launch",
		program = ask_program,
		cwd = function()
			return ask_cwd_or_default("${workspaceFolder}")
		end,
		sourceLanguages = { "rust", "c" },
		stopOnEntry = true,
		initCommand = get_rust_types,
	},
	{
		name = "Attach binary",
		type = "lldb",
		request = "attach",
		pid = dap_utils.pick_process,
		sourceLanguages = { "rust", "c" },
		stopOnEntry = true,
		initCommand = get_rust_types,
	},
}

dap.listeners.after.event_initialized["dapui_config"] = function()
	dapui.open()
end

dap.listeners.before.event_terminated["dapui_config"] = function()
	dapui.close()
end

dap.listeners.before.event_exited["dapui_config"] = function()
	dapui.close()
end

dapui.setup()
