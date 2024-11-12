-- add yours here

local map = vim.keymap.set

-- General mappings
map("n", "<Esc>", "<cmd>noh<CR>", { desc = "general clear highlights" })
map("n", "<C-/>", "gcc", { desc = "Comment toggle", remap = true })
map("v", "<C-/>", "gc", { desc = "Comment toggle", remap = true })
map("t", "<C-x>", "<C-\\><C-N>", { desc = "terminal escape terminal mode" })

-- Window mappings
map("n", "<leader>ws", "<cmd>split<CR>", { desc = "new horizontal split" })
map("n", "<leader>wv", "<cmd>vsplit<CR>", { desc = "new horizontal split" })
map("n", "<C-h>", "<C-w>h", { desc = "switch window left" })
map("n", "<C-l>", "<C-w>l", { desc = "switch window right" })
map("n", "<C-j>", "<C-w>j", { desc = "switch window down" })
map("n", "<C-k>", "<C-w>k", { desc = "switch window up" })

-- buffers
map("n", "<tab>", function()
	require("nvchad.tabufline").next()
end, { desc = "buffer goto next" })

map("n", "<S-tab>", function()
	require("nvchad.tabufline").prev()
end, { desc = "buffer goto prev" })

map("n", "<leader>x", function()
	require("nvchad.tabufline").close_buffer()
end, { desc = "buffer close" })

-- pickers
map("n", "<leader>b", "<cmd>Telescope buffers<CR>", { desc = "Open buffer picker" })
map("n", "<leader>f", "<cmd>Telescope find_files<CR>", { desc = "Open file picker" })
map("n", "<leader>/", "<cmd>Telescope live_grep<CR>", { desc = "Global search in workspace folder" })
map("n", "<leader>d", "<cmd>Telescope diagnostics bufnr=0<CR>", { desc = "Open diagnostic picker" })
map("n", "<leader>D", "<cmd>Telescope diagnostics<CR>", { desc = "Open workspace diagnostic picker" })
map("n", "<leader>s", "<cmd>Telescope lsp_references<CR>", { desc = "Select symbol references" })
map("n", "<leader>k", "<cmd>TodoTelescope<CR>", { desc = "List workspace keyword comments" })

-- LSP
vim.api.nvim_create_autocmd({ "LspAttach" }, {
	callback = function(args)
		local bufnr = args.buf

		local function opts(desc)
			return { buffer = bufnr, desc = desc }
		end

		map("n", "gD", vim.lsp.buf.declaration, opts("Goto declaration"))
		map("n", "gd", vim.lsp.buf.definition, opts("Goto definition"))
		map("n", "gi", vim.lsp.buf.implementation, opts("Goto implementation"))
		map("n", "gr", vim.lsp.buf.references, opts("Show references"))
		map("n", "<leader>r", function()
			require("nvchad.lsp.renamer")()
		end, opts("Rename symbol"))
		map({ "n", "v" }, "<leader>a", vim.lsp.buf.code_action, opts("Perform code action"))
		map("n", "K", vim.lsp.buf.hover, opts("Symbol documentation"))
	end,
})

-- terminals
map({ "n" }, "<leader>t", function()
	require("nvchad.term").toggle({ pos = "float", id = "floatterm" })
end, { desc = "Toggle terminal" })
