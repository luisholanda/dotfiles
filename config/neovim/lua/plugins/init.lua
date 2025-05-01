---@type (string | LazyPluginSpec)[]
return {
  {
    "iguanacucumber/magazine.nvim",
    name = "nvim-cmp",
    opts = function()
      local opts = require "nvchad.configs.cmp"
      local icons = require "nvchad.icons.lspkind"
      opts.formatting.fields = { "kind", "abbr" }
      opts.formatting.format = function(_, item)
        local icon = icons[item.kind] or ""
        item.kind = " " .. icon .. " "
        return item
      end
      opts.view = { enable = "native" }
      table.insert(opts.sources, { name = "codeium" })
      opts.window.completion.border = nil
      opts.window.completion.side_padding = 0
      opts.window.documentation.border = nil
      return opts
    end,
    config = function(_, opts)
      local cmp = require "cmp"
      cmp.setup(opts)

      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        preselect = "item",
        sources = {
          { name = "buffer" },
        },
        view = {
          enable = { name = "wildmenu", separator = "|" },
        },
      })
    end,
    dependencies = {
      {
        "Exafunction/codeium.nvim",
        cmd = { "Codeium" },
        opts = {
          enable_local_search = true,
          enable_index_service = true,
          wrapper = "steam-run",
        },
      },
      { "iguanacucumber/mag-nvim-lsp", name = "cmp-nvim-lsp", opts = {} },
      { "iguanacucumber/mag-nvim-lua", name = "cmp-nvim-lua" },
      { "iguanacucumber/mag-buffer", name = "cmp-buffer" },
      { "iguanacucumber/mag-cmdline", name = "cmp-cmdline" },
      "https://codeberg.org/FelipeLema/cmp-async-path",
    },
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      require("nvchad.configs.lspconfig").defaults()
      require "configs.lspconfig"
    end,
    dependencies = {
      {
        "stevearc/conform.nvim",
        config = function()
          require "configs.conform"
        end,
      },
      {
        "mfussenegger/nvim-lint",
        config = function()
          require "configs.nvim-lint"
        end,
      },
    },
  },
  {
    "icholy/lsplinks.nvim",
    dependencies = { "neovim/nvim-lspconfig" },
  },
  {
    "saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },
    dependencies = { "neovim/nvim-lspconfig" },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      incremental_selection = {
        enable = false,
      },
      indent = {
        enable = true,
      },
    },
  },
  "yorickpeterse/nvim-pqf",
  {
    "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
    config = function()
      vim.diagnostic.config {
        virtual_text = false,
        virtual_lines = {
          highlight_whole_line = false,
        },
      }
    end,
  },
  {
    "m4xshen/smartcolumn.nvim",
    opts = {
      colorcolumn = { "88", "100" },
    },
  },
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    opts = {
      graph_style = "unicode",
    },
  },
  {
    "folke/todo-comments.nvim",
    opts = {
      keywords = {
        SAFETY = { icon = "", color = "error" },
      },
      highlight = {
        keyword = "fg",
        pattern = [[.*<((KEYWORDS)%(\(.{-1,}\))?):]],
      },
    },
  },

  {
    "Julian/lean.nvim",
    event = { "BufReadPre *.lean", "BufNewFile *.lean" },
    dependencies = {
      "neovim/nvim-lspconfig",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    opts = {
      mappings = true,
    },
  },

  -- Colorschemes
  -- FIX: has a bad `force` argument to nvim_set_hl
  --{
  --  "slugbyte/lackluster.nvim",
  --  enable = false,
  --  lazy = false,
  --  priority = 1000,
  --  init = function()
  --    vim.cmd.colorscheme("lackluster-hack")
  --  end
  --},
  {
    "sho-87/kanagawa-paper.nvim",
    lazy = false,
    priority = 1000,
    init = function()
      vim.cmd.colorscheme "kanagawa-paper"
    end,
  },

  -- Disabled built-in stuff.
  {
    "nvim-tree/nvim-tree.lua",
    enabled = false,
  },
  {
    "williamboman/mason.nvim",
    enabled = false,
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    enabled = false,
  },
  --{
  --  "hrsh7th/nvim-cmp",
  --  enabled = false,
  --},
  --{
  --  "hrsh7th/cmp-buffer",
  --  enabled = false,
  --},
  --{
  --  "hrsh7th/cmp-cmdline",
  --  enabled = false,
  --},
  --{
  --  "hrsh7th/cmp-nvim-lsp",
  --  enabled = false,
  --},
  --{
  --  "hrsh7th/cmp-nvim-lua",
  --  enabled = false,
  --},
  --{
  --  "hrsh7th/cmp-path",
  --  enabled = false,
  --},

  {
    "nvchad/ui",
    config = function()
      require "nvchad"
    end,
  },
  {
    "nvchad/base46",
    lazy = true,
    build = function()
      require("base46").load_all_highlights()
    end,
  },
  "nvzone/volt",
}
