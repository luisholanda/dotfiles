require("nvchad.options")

vim.o.cursorlineopt = "both"

vim.o.relativenumber = true

local rnu_toggle = vim.api.nvim_create_augroup("RelNumToggle", { clear = true })

vim.api.nvim_create_autocmd({ "InsertEnter", "InsertLeave" }, {
	group = rnu_toggle,
	callback = function(args)
		vim.o.relativenumber = args.event == "InsertLeave"
	end,
})
