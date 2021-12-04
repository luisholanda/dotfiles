local o = vim.o or {}
local g = vim.g or {}

o.shell = vim.env["SHELL"]
g.mapleader = ";"

g.loaded_python_provider = 0
g.python3_host_prog = vim.fn.expand("~/.pyenv/versions/neovim/bin/python")
o.pyxversion = 3

o.signcolumn = "yes:1"
o.synmaxcol = 240

o.number = true
o.cursorline = true
o.colorcolumn = "+0,+10"

o.showtabline = 0
o.laststatus = 2
o.ruler = false

-- number of lines at the beginning and end of files checked for file-specific vars
o.modelines = 1

-- time waited for key press(es) to complete. It makes for a faster key response.
o.ttimeout = true
o.ttimeoutlen = 2

-- reload files changed outside of Vim not currently modified in Vim (needs below)
o.autoread = true
vim.api.nvim_command("autocmd FocusGained,BufEnter * checktime")

-- make Backspace work like Delete
o.backspace = "indent,eol,start"

-- don't create `filename~` backups
o.backup = false

-- c: don't give |ins-completion-menu| messages.
-- F: don't show statusline in unfocused buffers.
o.shortmess = vim.o.shortmess .. "cF"

-- number of lines offset when jumping
o.scrolloff = 2
o.sidescrolloff = 5

-- Tab key enters 2 spaces
-- To enter a TAB character when 'expandtab' is in effect, CTRL-v-TAB.
o.expandtab = true
o.tabstop = 2
o.shiftwidth = 2
o.softtabstop = o.tabstop

-- Indent new line the same as the preceding line
o.autoindent = true

-- make scrolling and painting fast.
o.lazyredraw = true

-- update changes faster.
o.updatetime = 100

-- Better behaviour from autocomplete pop-up.
o.completeopt = "noinsert,menuone,noselect"
o.pumheight = 25

-- highlight matching parenthesis, braces, brackets, etc.
o.showmatch = true

-- http://vim.wikia.com/wiki/Searching
o.incsearch = true
o.ignorecase = true
o.smartcase = true
o.inccommand = "split"

-- open new buffers without saving current modifications (buffer remains open).
o.hidden = true

-- http://stackoverflow.com/questions/9511253/how-to-effectively-use-vim-wildmenu
o.wildmenu = true
o.wildmode = "list:longest,full"
o.wildignore = vim.o.wildignore .. "vendor/**,node_modules/**,target/**"

if vim.fn.executable("pbcopy") == 1 then
    copy = "pbcopy"
    paste = "pbpaste"
elseif vim.fn.executable("wl-copy") == 1 then
    copy = "wl-copy -n"
    paste = "wl-paste -n"
end

g.clipboard = {
    name = copy,
    copy = { ["+"] = copy, ["*"] = copy },
    paste = { ["+"] = paste, ["*"] = paste },
    cache_enabled = 1,
}
o.clipboard = "unnamedplus"

-- Configure undo history
o.undofile = true
o.undodir = vim.env.HOME .. "/.local/share/nvim/vimundo"
o.undolevels = 1000
o.undoreload = 10000
