-- lua/plugins/lsp.lua
return {

  -- ── Mason ────────────────────────────────────────────────────────────────
  {
    "williamboman/mason.nvim",
    cmd   = "Mason",
    build = ":MasonUpdate",
    config = function()
      require("mason").setup({
        ui = {
          border = "rounded",
          icons  = { package_installed = "✓", package_pending = "➜", package_uninstalled = "✗" },
        },
      })
    end,
  },

  -- ── Formatting (conform.nvim) ────────────────────────────────────────────
  {
    "stevearc/conform.nvim",
    event = "VeryLazy",
    cmd   = "ConformInfo",
    keys  = {
      {
        "<leader>cf",
        function() require("conform").format({ async = true, lsp_fallback = true }) end,
        desc = "Format buffer",
      },
    },
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          lua             = { "stylua" },
          python          = { "isort", "black" },
          javascript      = { "prettier" },
          typescript      = { "prettier" },
          typescriptreact = { "prettier" },
          javascriptreact = { "prettier" },
          html            = { "prettier" },
          css             = { "prettier" },
          json            = { "prettier" },
          yaml            = { "prettier" },
          markdown        = { "prettier" },
          c               = { "clang_format" },
          cpp             = { "clang_format" },
          astro           = { "prettier" },
        },
      })
    end,
  },

  -- ── nvim-lint (async linting) ────────────────────────────────────────────
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufNewFile", "BufWritePost" },
    config = function()
      local lint = require("lint")
      lint.linters_by_ft = {
        python          = { "ruff" },
        javascript      = { "eslint_d" },
        typescript      = { "eslint_d" },
        typescriptreact = { "eslint_d" },
        javascriptreact = { "eslint_d" },
        -- C/C++ handled by clangd (--clang-tidy flag)
      }
      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
        callback = function() lint.try_lint() end,
      })
    end,
  },

  -- ── blink.cmp (modern completion — replaces nvim-cmp) ───────────────────
  -- Zero deprecation warnings, faster, built for Nvim 0.10+
  {
    "saghen/blink.cmp",
    lazy = false,
    version = "*",
    dependencies = { "rafamadriz/friendly-snippets" },
    opts = {
      keymap = {
        preset = "default",
        ["<CR>"]      = { "accept", "fallback" },
        ["<Tab>"]     = { "select_next", "snippet_forward", "fallback" },
        ["<S-Tab>"]   = { "select_prev", "snippet_backward", "fallback" },
        ["<C-e>"]     = { "cancel", "fallback" },
        ["<C-b>"]     = { "scroll_documentation_up", "fallback" },
        ["<C-f>"]     = { "scroll_documentation_down", "fallback" },
        ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
      },
      appearance = {
        use_nvim_cmp_as_default = false,
        nerd_font_variant = "mono",
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },
      completion = {
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
          window = { border = "rounded" },
        },
        menu = {
          border = "rounded",
          draw = {
            columns = {
              { "label", "label_description", gap = 1 },
              { "kind_icon", "kind" },
            },
          },
        },
        ghost_text = { enabled = true },
      },
      signature = { enabled = true, window = { border = "rounded" } },
    },
  },

  -- ── LSP (nvim-lspconfig + mason-lspconfig) ──────────────────────────────
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "saghen/blink.cmp",
    },
    config = function()
      -- ── mason-lspconfig ──────────────────────────────────────────────────
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls", "pyright", "ts_ls",
          "html", "cssls", "jsonls",
          "clangd", "astro",
        },
        automatic_installation = true,
      })

      -- ── Auto-install formatters + linters via Mason ──────────────────────
      local mason_registry = require("mason-registry")
      local tools = {
        "clang-format", "stylua",
        "black", "isort", "ruff",
        "prettier", "eslint_d",
      }
      mason_registry.refresh(function()
        for _, tool in ipairs(tools) do
          local ok, pkg = pcall(function() return mason_registry.get_package(tool) end)
          if ok and not pkg:is_installed() then pkg:install() end
        end
      end)

      -- ── Diagnostics UI (0.11+ API, no sign_define) ───────────────────────
      vim.diagnostic.config({
        virtual_text     = { prefix = "●", source = "if_many" },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = " ",
            [vim.diagnostic.severity.WARN]  = " ",
            [vim.diagnostic.severity.HINT]  = "󰠠 ",
            [vim.diagnostic.severity.INFO]  = " ",
          },
        },
        underline        = true,
        update_in_insert = false,
        severity_sort    = true,
        float            = { border = "rounded", source = "always" },
      })

      -- ── LSP capabilities from blink.cmp ─────────────────────────────────
      local capabilities = require("blink.cmp").get_lsp_capabilities()
      capabilities.textDocument.foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly     = true,
      }

      local function setup(server, extra)
        extra = extra or {}
        extra.capabilities = vim.tbl_deep_extend("force", capabilities, extra.capabilities or {})
        vim.lsp.config(server, extra)
        vim.lsp.enable(server)
      end

      -- ── Server configs ───────────────────────────────────────────────────
      setup("lua_ls", {
        settings = {
          Lua = {
            diagnostics  = { globals = { "vim" } },
            workspace    = { checkThirdParty = false },
            telemetry    = { enable = false },
            completion   = { callSnippet = "Replace" },
          },
        },
      })

      setup("pyright", {
        settings = {
          python = {
            analysis = {
              typeCheckingMode       = "basic",
              autoSearchPaths        = true,
              useLibraryCodeForTypes = true,
            },
          },
        },
      })

      setup("ts_ls", {
        settings = {
          typescript = { inlayHints = { includeInlayParameterNameHints = "all" } },
          javascript = { inlayHints = { includeInlayParameterNameHints = "all" } },
        },
      })

      setup("clangd", {
        cmd = {
          "clangd",
          "--background-index",
          "--clang-tidy",
          "--header-insertion=iwyu",
          "--completion-style=detailed",
          "--function-arg-placeholders",
          "--fallback-style=llvm",
        },
        init_options = {
          usePlaceholders    = true,
          completeUnimported = true,
          clangdFileStatus   = true,
        },
      })

      setup("html")
      setup("cssls")
      setup("jsonls")
      setup("astro")
    end,
  },
}
