local tsconfigs = nil

local M = {}

function M.setup()
    tsconfigs = tsconfigs or require("nvim-treesitter.configs")

    tsconfigs.setup {
        ensure_installed = "maintained",
        highlight = { enable = true, use_languagetree = false },
        indent = { enable = true },
    }
end

return M
