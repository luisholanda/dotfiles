local borders_cache = {}
local last_dim = ""

local function get_borders(width, height)
    -- We can only cache the
    local key = string.format("%d-%d", width, height)
    if key == last_dim then return borders_cache end

    local top = "┏" .. string.rep("━", width - 2) .. "┓"
    local mid = "┃" .. string.rep(" ", width - 2) .. "┃"
    local bot = "┗" .. string.rep("━", width - 2) .. "┛"

    local borders = { top }
    for _ = 2, height - 1, 1 do table.insert(borders, mid) end
    table.insert(borders, bot)

    borders_cache = borders

    return borders
end

local nvim_create_buf = vim.api.nvim_create_buf
local nvim_buf_set_lines = vim.api.nvim_buf_set_lines
local nvim_open_win = vim.api.nvim_open_win
local nvim_command = vim.api.nvim_command

local function create_centered_window()
    local col = vim.o.columns
    local lin = vim.o.lines

    local width = math.min(col - 4, math.max(80, col - 20))
    local height = math.min(lin - 4, math.max(20, lin - 10))
    local top = (lin - height) / 2 - 1
    local left = (col - width) / 2
    local opts = {
        relative = "editor",
        row = top,
        col = left,
        width = width,
        height = height,
        style = "minimal",
    }

    local lines = get_borders(width, height)
    local buf = nvim_create_buf(false, true)
    nvim_buf_set_lines(buf, 0, -1, true, lines)
    nvim_open_win(buf, true, opts)

    opts.row = opts.row + 1
    opts.height = opts.height - 2
    opts.col = opts.col + 2
    opts.width = opts.width - 4

    nvim_open_win(nvim_create_buf(false, true), true, opts)
    nvim_command(string.format("au BufWipeout <buffer> exe 'bw %d'", buf))
end

return { create_centered_window = create_centered_window }
