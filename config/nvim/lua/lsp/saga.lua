local colors = require("lsp-colors")
local saga = require("lspsaga")
local trouble = require("trouble")

local M = {}

function M.setup()
    colors.setup()
    saga.init_lsp_saga {
        border_style = "round",
        code_action_prompt = { sign = false },
        use_saga_diagnostic_sign = false,
    }
    trouble.setup { auto_close = true, auto_fold = true }
end

return M
