local autocmd_group = vim.api.nvim_create_augroup("LspCustomAutoCmds", { clear = true })

---@param client vim.lsp.Client
---@param bufnr number
local function on_attach(client, bufnr)
  vim.api.nvim_create_autocmd("CursorHold", {
    buffer = bufnr,
    group = autocmd_group,
    callback = function()
      vim.diagnostic.open_float(nil, {
        focusable = false,
        close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
        border = "rounded",
        source = "always",
        prefix = " ",
        scope = "cursor",
      })
    end,
  })

  if client.server_capabilities.documentFormattingProvider then
    vim.api.nvim_create_autocmd("InsertLeave", {
      buffer = bufnr,
      group = autocmd_group,
      callback = function()
        require("conform").format({ bufnr = bufnr, async = true }, nil)
      end,
    })
  end

  if client.server_capabilities.inlayHintProvider then
    vim.lsp.inlay_hint.enable(true)
  end

  if client.name == "ruff_lsp" then
    -- Prefer hover from pyright.
    client.server_capabilities.hoverProvider = false
  end
end

---@type table<string, vim.lsp.Config>
local servers = {
  clangd = {
    filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
  },
  cmake = {},
  dockerls = {},
  hls = {},
  nil_ls = {
    settings = {
      ["nil"] = {
        diagnostics = {
          excludedFiles = { "Cargo.nix" },
        },
        nix = {
          flake = {
            autoArchive = true,
            autoEvalInputs = true,
          },
        },
      },
    },
  },
  -- Go
  gopls = {
    settings = {
      gopls = {
        gofumpt = true,
        semanticTokens = true,
        noSemanticString = true,
        noSemanticNumber = true,
        staticcheck = true,
        vulcheck = true,
        analyses = {
          loopclosure = false,
          shadow = true,
        },
        hints = {
          assignVariableType = true,
          constantValues = true,
          parameterNames = true,
        },
      },
    },
  },
  golangci_lint_ls = {},
  -- Python
  basedpyright = {
    settings = {
      basedpyright = {
        disableOrganizeImports = true,
        analysis = {
          autoImportCompletions = true,
          typeCheckingMode = "strict",
        },
      },
    },
  },
  ruff = {
    init_options = {
      settings = {
        lint = {
          select = {
            -- pyflakes
            "F",
            -- pycodestyle
            "E",
            "W",
            -- mccabe
            "C90",
            -- isort
            "I",
            -- pep8-naming
            "N",
            -- flake8-annotation
            "ANN",
            -- flake8-async
            "ASYNC",
            -- flake8-bugbear
            "B",
            -- flake8-comprehensions
            "C4",
            -- flake8-datetime
            "DTZ",
            -- flake8-errmsg
            "EM",
            -- flake8-pie
            "PIE",
            -- flake8-pyi
            "PYI",
            -- flake8-pytest-style
            "PT",
            -- flake8-simplify
            "SIM",
            -- pandas-vet
            "PD",
            -- pylint
            "PL",
            -- tryceratops
            "TRY",
            -- fastapi
            "FAST",
            -- perflint
            "PERF",
            -- refurb
            "FURB",
            -- ruff
            "RUFF",
          },
        },
      },
    },
  },
  starpls = {
    cmd = { "starpls", "server", "--experimental_enable_label_completions", "--experimental_infer_ctx_attributes" },
  },

  terraformls = {
    filetypes = { "terraform", "tf", "hcl" },
  },
  yamlls = {
    settings = {
      yaml = {
        keyOrdering = false,
      },
    },
  },
  zls = {},
  rust_analyzer = {
    settings = {
      ["rust-analyzer"] = {
        assist = {
          emitMustUse = true,
        },
        cargo = {
          features = "all",
        },
        check = {
          command = "clippy",
        },
        checkOnSave = true,
        imports = {
          prefix = "crate",
        },
        inlayHints = {
          expressionAdjustmentHints = {
            enable = "always",
            hideOutsideUnsafe = true,
          },
          lifetimeElisionHints = {
            enable = "skip_trivial",
          },
          typeHints = {
            hideClsoureInitialization = true,
            hideNamedConstructor = true,
          },
        },
        lens = {
          references = {
            adt = { enable = true },
            method = { enable = true },
            trait = { enable = true },
          },
          run = { enable = false },
        },
      },
    },
  },
}

vim.lsp.inlay_hint.enable()

vim.lsp.config("*", {
  on_attach = on_attach,
  capabilities = require("nvchad.configs.lspconfig").capabilities,
})

-- lsps with default config
for server, config in pairs(servers) do
  vim.lsp.config(server, config)
  vim.lsp.enable(server)
end
