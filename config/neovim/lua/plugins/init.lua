---@type (string | LazyPluginSpec)[]
return {
  { import = "nvchad.blink.lazyspec" },
  {
    "Saghen/blink.cmp",
    opts = {
      completion = {
        keyword = { range = "full" },
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
        trigger = {
          show_on_insert_on_trigger_character = true,
        },
      },
      signature = { enabled = true },
    },
    dependencies = {
      "xzbdmw/colorful-menu.nvim",
    },
  },
  {
    "neovim/nvim-lspconfig",
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
      {
        "icholy/lsplinks.nvim",
        config = function()
          local lsplinks = require "lsplinks"
          lsplinks.setup()
          vim.keymap.set("n", "gx", lsplinks.gx)
        end,
      },
    },
  },
  {
    "saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },
    dependencies = { "neovim/nvim-lspconfig" },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    config = function()
      dofile(vim.g.base46_cache .. "treesitter")
    end,
    build = ":TSUpdate",
  },
  { "yorickpeterse/nvim-pqf", lazy = false },
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
    config = function()
      dofile(vim.g.base46_cache .. "neogit")
    end,
  },
  {
    "folke/todo-comments.nvim",
    lazy = false,
    opts = {
      -- SAFETY:
      keywords = {
        SAFETY = { icon = "", color = "error" },
      },
      search = {
        pattern = [[.*<(KEYWORDS)\s*\(.*\)\s*:]],
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
    lazy = false,
    build = function()
      require("base46").compile()
      require("base46").load_all_highlights()
    end,
  },
  "nvzone/volt",
}
