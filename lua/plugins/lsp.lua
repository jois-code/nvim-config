-- lua/plugins/lsp.lua
return {

  -- ── Mason (LSP/DAP/linter/formatter installer) ───────────────────────────
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
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
  -- Provides auto-format-on-save via a clean, fast formatter layer.
  -- Formatters must be installed separately (mason installs them).
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
          lua        = { "stylua" },
          python     = { "isort", "black" },
          javascript = { "prettier" },
          typescript = { "prettier" },
          typescriptreact = { "prettier" },
          javascriptreact = { "prettier" },
          html       = { "prettier" },
          css        = { "prettier" },
          json       = { "prettier" },
          yaml       = { "prettier" },
          markdown   = { "prettier" },
          c          = { "clang_format" },
          cpp        = { "clang_format" },
          astro      = { "prettier" },
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
      local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"

      lint.linters_by_ft = {
        python     = { "ruff" },
        javascript = { "eslint_d" },
        typescript = { "eslint_d" },
        typescriptreact = { "eslint_d" },
        javascriptreact = { "eslint_d" },
        -- C/C++ linting is handled by clangd LSP directly (--clang-tidy flag)
        -- No separate linter needed here
      }

      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },

  -- ── LSP (nvim-lspconfig + mason-lspconfig) ──────────────────────────────
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
      "onsails/lspkind.nvim",
    },
    config = function()
      -- ── mason-lspconfig ─────────────────────────────────────────────────
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls", "pyright", "ts_ls",
          "html", "cssls", "jsonls",
          "clangd", "astro",
        },
        automatic_installation = true,
      })

      -- Auto-install non-LSP tools (formatters + linters) via Mason
      local mason_registry = require("mason-registry")
      local tools = {
        "clang-format",
        "stylua",
        "black", "isort", "ruff",
        "prettier", "eslint_d",
      }
      mason_registry.refresh(function()
        for _, tool in ipairs(tools) do
          local ok, pkg = pcall(function() return mason_registry.get_package(tool) end)
          if ok and not pkg:is_installed() then
            pkg:install()
          end
        end
      end)



      -- ── Diagnostics UI ──────────────────────────────────────────────────
      vim.diagnostic.config({
        virtual_text    = { prefix = "●", source = "if_many" },
        signs           = true,
        underline       = true,
        update_in_insert = false,
        severity_sort   = true,
        float = { border = "rounded", source = "always" },
      })

      local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
      end

      -- ── nvim-cmp ────────────────────────────────────────────────────────
      vim.g.cmp_is_enabled = true
      vim.keymap.set("n", "<leader>ti", function()
        vim.g.cmp_is_enabled = not vim.g.cmp_is_enabled
        if vim.g.cmp_is_enabled then
          vim.notify("Intellisense enabled", vim.log.levels.INFO)
        else
          require("cmp").abort()
          vim.notify("Intellisense disabled", vim.log.levels.WARN)
        end
      end, { desc = "Toggle Intellisense" })

      local cmp     = require("cmp")
      local luasnip = require("luasnip")
      local lspkind = require("lspkind")

      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        enabled = function()
          if vim.api.nvim_get_mode().mode == "c" then return true end
          return vim.g.cmp_is_enabled
        end,
        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },
        window = {
          completion    = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"]     = cmp.mapping.scroll_docs(-4),
          ["<C-f>"]     = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"]     = cmp.mapping.abort(),
          ["<CR>"]      = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_next_item()
            elseif luasnip.expand_or_locally_jumpable() then luasnip.expand_or_jump()
            else fallback() end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_prev_item()
            elseif luasnip.locally_jumpable(-1) then luasnip.jump(-1)
            else fallback() end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp", priority = 1000 },
          { name = "luasnip",  priority = 750  },
          { name = "buffer",   priority = 500  },
          { name = "path",     priority = 250  },
        }),
        formatting = {
          format = lspkind.cmp_format({
            mode          = "symbol_text",
            maxwidth      = 50,
            ellipsis_char = "...",
            before = function(entry, vim_item)
              -- Show source name
              vim_item.menu = ({
                nvim_lsp = "[LSP]",
                luasnip  = "[Snip]",
                buffer   = "[Buf]",
                path     = "[Path]",
              })[entry.source.name]
              return vim_item
            end,
          }),
        },
        experimental = { ghost_text = { hl_group = "CmpGhostText" } },
      })

      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({ { name = "path" }, { name = "cmdline" } }),
      })
      cmp.setup.cmdline("/", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = { { name = "buffer" } },
      })

      -- ── LSP server configs ───────────────────────────────────────────────
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
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

      setup("lua_ls", {
        settings = {
          Lua = {
            diagnostics      = { globals = { "vim" } },
            workspace        = { checkThirdParty = false },
            telemetry        = { enable = false },
            completion       = { callSnippet = "Replace" },
          },
        },
      })

      setup("pyright", {
        settings = {
          python = {
            analysis = {
              typeCheckingMode    = "basic",
              autoSearchPaths     = true,
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
