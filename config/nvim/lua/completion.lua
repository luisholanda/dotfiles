local snippets = require("snippets")
local complete = vim.fn["compe#complete"]
local confirm = vim.fn["compe#confirm"]

local t = function(str) return vim.api.nvim_replace_termcodes(str, true, true, true) end

local check_back_space = function()
    local col = vim.fn.col(".") - 1
    if col == 0 or vim.fn.getline("."):sub(col, col):match("%s") then
        return true
    else
        return false
    end
end

local in_snippet = function()
    local _, expanded = snippets.lookup_snippet_at_cursor()
    return expanded ~= nil
end

-- Use (s-)tab to:
--- move to prev/next item in completion menuone
--- jump to prev/next snippet's placeholder
_G.tab_complete = function()
    if vim.fn.pumvisible() == 1 then
        return t "<C-n>"
    elseif check_back_space() then
        return t "<Tab>"
    elseif in_snippet() then
        return snippets.expand_or_advance(1)
    else
        return complete()
    end
end
_G.s_tab_complete = function()
    if vim.fn.pumvisible() == 1 then
        return t "<C-p>"
    elseif in_snippet() then
        return snippets.advance_snippet(-1)
    else
        return t "<S-Tab>"
    end
end
_G.enter_confirm = function()
    if snippets.has_active_snippet() then
        return snippets.expand_or_advance(1)
    elseif vim.fn.pumvisible() == 1 then
        return confirm("<CR>")
    else
        return t "<CR>"
    end
end

vim.api.nvim_set_keymap("i", "<CR>", "compe#confirm('<CR>')", { expr = true })
vim.api.nvim_set_keymap("i", "<C-Space>", "compe#complete()", { expr = true })
vim.api.nvim_set_keymap("i", "<C-e>", "compe#close('<C-e>')", { expr = true })
vim.api.nvim_set_keymap("i", "<Tab>", "v:lua.tab_complete()", { expr = true })
vim.api.nvim_set_keymap("s", "<Tab>", "v:lua.tab_complete()", { expr = true })
vim.api.nvim_set_keymap("i", "<S-Tab>", "v:lua.s_tab_complete()", { expr = true })
vim.api.nvim_set_keymap("s", "<S-Tab>", "v:lua.s_tab_complete()", { expr = true })
