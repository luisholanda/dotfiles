local gl = require("galaxyline")
local glc = require("galaxyline.condition")
local gls = gl.section
gl.short_line_list = {}

local colors = {
    bg = "#2f3242",
    line_bg = "#2f3242",
    lightbg = "#3f445b",
    fg = "#e1e3e4",
    fg_green = "#65a380",
    darkblue = "#354157",
    red = "#fb617e",
    orange = "#f89860",
    yellow = "#edc763",
    green = "#9ed06c",
    blue = "#6dcae8",
    magenta = "#bb97ee",
    nord = "#81A1C1",
    greenYel = "#EBCB8B",
}

local fixed = function(raw) return function() return raw end end

local left_sep = fixed("")
local right_sep = fixed("")

local MODES_COLORS_MAP = {
    n = colors.nord,
    i = colors.darkblue,
    c = colors.green,
    [""] = colors.yellow,
    v = colors.yellow,
    r = colors.red,
}

local has_lsp_client =
    function() return vim.tbl_isempty(vim.lsp.get_active_clients(0)) end

gls.left[1] = {
    LeftLeftSep = {
        provider = left_sep,
        highlight = function()
            return { MODES_COLORS_MAP[vim.fn.mode()], colors.bg }
        end,
    },
}
gls.left[2] = {
    StatusIcon = {
        provider = fixed("  "),
        highlight = function()
            return { colors.bg, MODES_COLORS_MAP[vim.fn.mode()] }
        end,
        separator = " ",
        separator_highlight = { colors.lightbg, colors.lightbg },
    },
}
gls.left[3] = {
    FileIcon = {
        provider = "FileIcon",
        condition = glc.buffer_not_empty,
        highlight = {
            require("galaxyline.provider_fileinfo").get_file_icon_color, colors.lightbg,
        },
    },
}
gls.left[4] = {
    FileName = {
        provider = { "FileName", "FileSize" },
        condition = glc.buffer_not_empty,
        highlight = { colors.fg, colors.lightbg },
    },
}
gls.left[5] = {
    LeftRightSep = {
        provider = right_sep,
        separator = " ",
        highlight = { colors.lightbg, colors.bg },
    },
}

local gitstatus = function() return vim.b.gitsigns_status_dict or {} end

gls.mid[1] = {
    MidLeftSep = {
        provider = left_sep,
        condition = glc.hide_in_width,
        highlight = { colors.lightbg, colors.bg },
    },
}
gls.mid[2] = {
    DiffAdd = {
        provider = function() return string.format("%d ", gitstatus().added or 0) end,
        condition = glc.hide_in_width,
        icon = "  ",
        highlight = { colors.yellow, colors.lightbg },
    },
}
gls.mid[3] = {
    DiffModified = {
        provider = function()
            return string.format("%d ", gitstatus().changed or 0)
        end,
        condition = glc.hide_in_width,
        icon = "   ",
        highlight = { colors.orange, colors.lightbg },
    },
}
gls.mid[4] = {
    DiffRemoved = {
        provider = function()
            return string.format("%d ", gitstatus().removed or 0)
        end,
        condition = glc.hide_in_width,
        icon = "   ",
        highlight = { colors.red, colors.lightbg },
    },
}
gls.mid[5] = {
    DiagnosticError = {
        provider = function()
            if #vim.lsp.buf_get_clients() == 0 then
                return 0
            else
                return vim.lsp.diagnostic.get_count("Error") or 0
            end
        end,
        icon = "   ",
        condition = glc.hide_in_width,
        highlight = { colors.red, colors.darkblue },
    },
}
gls.mid[6] = {
    DiagnosticWarn = {
        provider = function()
            if #vim.lsp.buf_get_clients() == 0 then
                return 0
            else
                return vim.lsp.diagnostic.get_count("Warning") or 0
            end
        end,
        icon = "   ",
        condition = glc.hide_in_width,
        highlight = { colors.orange, colors.darkblue },
    },
}
gls.mid[7] = {
    MidRightSep = {
        provider = right_sep,
        condition = glc.hide_in_width,
        highlight = { colors.darkblue, colors.bg },
    },
}

gls.right[1] = {
    RightLeftSep = { provider = left_sep, highlight = { colors.fg_green, colors.bg } },
}
gls.right[2] = {
    LspStatus = {
        provider = require("lsp-status").status_progress,
        condition = glc.buffer_not_empty,
        highlight = { colors.fg, colors.fg_green },
    },
}
gls.right[3] = {
    FilePos = {
        provider = "LineColumn",
        highlight = { colors.bg, colors.fg },
        separator = " ",
        separator_highlight = { colors.bg, colors.fg },
    },
}
gls.right[4] = {
    ScrollBar = {
        provider = "ScrollBar",
        highlight = { colors.bg, colors.fg },
        separator = " ",
        separator_highlight = { colors.bg, colors.fg },
    },
}
gls.right[5] = {
    RightRightSep = {
        provider = right_sep,
        highlight = { colors.fg, colors.bg },
        separator = " ",
        separator_highlight = { colors.bg, colors.fg },
    },
}

vim.cmd("hi GalaxylineFillSection guibg=" .. colors.bg)
