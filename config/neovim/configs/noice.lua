--- @type NoiceConfig
local opts = {
	cmdline = { enabled = false },
	messages = { enabled = false },
	presets = {
		bottom_search = true,
		long_message_to_split = true,
		inc_rename = true,
	},
	lsp = {
		hover = { enabled = false },
		signature = { enabled = false },
		override = {
			["vim.lsp.util.convert_input_to_markdown_lines"] = true,
			["vim.lsp.util.stylize_markdown"] = true,
			["cmp.entry.get_documentation"] = true,
		},
	},
}

require("noice").setup(opts)

local noice_lsp = require("noice.lsp")

vim.keymap.set({ "n", "i", "s" }, "<c-f>", function()
	if not noice_lsp.scroll(4) then
		return "<c-f>"
	end
end, { silent = true, expr = true })

vim.keymap.set({ "n", "i", "s" }, "<c-b>", function()
	if not noice_lsp.scroll(-4) then
		return "<c-b>"
	end
end, { silent = true, expr = true })
