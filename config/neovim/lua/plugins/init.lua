---@type (string | LazyPluginSpec)[]
return {
  { import = "nvchad.blink.lazyspec" },
  {
    "Saghen/blink.cmp",
    opts = {
      completion = {
        keyword = { range = "full" },
      },
      menu = {
        draw = {
          components = {
            label = {
              text = function(ctx)
                return require("colorful-menu").blink_components_text(ctx)
              end,
              highlight = function(ctx)
                return require("colorful-menu").blink_components_highlight(ctx)
              end,
            },
          },
        },
      },
      signature = { enabled = true },
      trigger = {
        show_on_insert_on_trigger_character = true,
      },
    },
    dependencies = {
      "xzbdmw/colorful-menu.nvim",
    },
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      require("nvchad.configs.lspconfig").defaults()
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
    rocks = { enabled = false },
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

  {
    "nvchad/ui",
    config = function()
      require "nvchad"
    end,
  },
  {
    "nvchad/base46",
    branch = "v3.0",
    lazy = true,
    build = function()
      require("base46").load_all_highlights()
    end,
  },
  "nvzone/volt",
}
