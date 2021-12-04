local utils = require("utils")

vim.g.sonokai_style = "andromeda"
vim.g.sonokai_enable_italic = 1
vim.cmd [[colorscheme sonokai]]

utils.create_augroup("ItalicComments", {
    { "ColorScheme", "*", "highlight Comment cterm=italic gui=italic" },
})

utils.create_augroup("BoldKeywords", {
    { "ColorScheme", "*", "highlight Keyword cterm=bold gui=bold" },
})
