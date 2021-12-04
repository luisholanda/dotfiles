local g = vim.g;
local opt = vim.opt;

g.polyglot_disabled = { "sensible" }
g.loaded_matchit = 1

g.async_open = 14

g.indent_blankline_char = "▏"
g.indent_blankline_use_treesitter = 1

g.indicator_errors = ""
g.indicator_warnings = ""
g.indicator_info = "כֿ"
g.indicator_hint = "!"
g.indicator_ok = ""
g.spinner_frames = { "⣾", "⣽", "⣻", "⢿", "⡿", "⣟", "⣯", "⣷" }

g.db_ui_env_variable_url = "DATABASE_URL"
g.db_ui_env_variable_name = "DB_NAME"

g.fzf_colors = {
    fg = { "fg", "Normal" },
    bg = { "bg", "Normal" },
    hl = { "fg", "Comment" },
    ["fg+"] = { "fg", "CursorLine", "CursorColumn", "Normal" },
    ["bg+"] = { "bg", "CursorLine", "CursorColumn" },
    ["hl+"] = { "fg", "Statement" },
    info = { "fg", "PreProc" },
    border = { "fg", "Ignore" },
    prompt = { "fg", "Conditional" },
    pointer = { "fg", "Exception" },
    marker = { "fg", "Keyword" },
    spinner = { "fg", "Label" },
    header = { "fg", "Comment" },
}

g.fzf_commits_log_options = "--graph --color=always " ..
                                "--format=\"%C(yellow)%h%C(read)%d%C(reset)\" " ..
                                "- %C(bold green)(%ar)%C(reset) %s %C(blue)<%an>%C(reset)"

g.tex_flavor = "latex"

opt.foldmethod = "expr"
opt.foldexpr = "nvim_treesitter#foldexpr()"

local disabled_builtins = {
    "netrw",
    "netrwPlugin",
    "netrwSettings",
    "netrwFileHandlers",
    "gzip",
    "zip",
    "zipPlugin",
    "tar",
    "tarPlugin",
    "getscript",
    "getscriptPlugin",
    "vimball",
    "vimballPlugin",
    "2html_plugin",
    "logipat",
    "rrhelper",
    "spellfile_plugin",
    "matchit"
}

for _, plugin in pairs(disabled_builtins) do
    g["loaded_" .. plugin] = 1
end

-- Configure neovide
g.neovide_cursor_animation_length = 0
