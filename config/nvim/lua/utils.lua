local M = {}
local cmd = vim.cmd

-- Create a augroup with a given name and autocmds.
--
-- @param name: The name of the augroup.
-- @param autocmds: The autocmds to include in the augroup.
--    Each autocmd should be a table containing the elements following
--    the VimScript API.
function M.create_augroup(name, autocmds)
    cmd("augroup " .. name)
    cmd("autocmd!")

    for _, autocmd in ipairs(autocmds) do
        cmd("autocmd " .. table.concat(autocmd, " "))
    end
    cmd("augroup END")
end

return M
