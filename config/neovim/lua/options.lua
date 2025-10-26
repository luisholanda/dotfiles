require "nvchad.options"

vim.o.cursorlineopt = "both"
vim.o.relativenumber = true
vim.o.exrc = true

local rnu_toggle = vim.api.nvim_create_augroup("RelNumToggle", { clear = true })

vim.api.nvim_create_autocmd({ "InsertEnter", "InsertLeave" }, {
  group = rnu_toggle,
  callback = function(args)
    vim.o.relativenumber = args.event == "InsertLeave"
    if not vim.o.relativenumber then
      vim.o.number = true
    end
  end,
})

vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
