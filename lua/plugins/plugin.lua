return {
  -- Theme
  --[[{
    "olimorris/onedarkpro.nvim",
    priority = 1000,
    config = function()
      vim.cmd("colorscheme onedark")
    end,
  },]]
   {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000, -- load early so other plugins (lualine, treesitter, etc.) see the colors
  config = function()
    require("catppuccin").setup({
      flavour = "mocha",                 -- latte, frappe, macchiato, mocha
      background = { light = "latte", dark = "mocha" },
      transparent_background = false,
      term_colors = true,
      integrations = {
        -- enable integrations you use; examples:
        nvimtree = true,
        treesitter = true,
        telescope = true,
        lualine = true,
        gitsigns = true,
        indent_blankline = { enabled = true },
      },
    })
    vim.cmd.colorscheme("catppuccin")
  end,
    },
  -- Treesitter: better syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects", -- Better text objects
    },
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "lua", "python", "javascript", "typescript", "html", "css", "json", "markdown" ,"c"},
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<C-space>",
            node_incremental = "<C-space>",
            scope_incremental = false,
            node_decremental = "<bs>",
          },
        },
      })
    end,
  },

  -- Telescope: fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Find Buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Find Help" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent Files" },
      { "<leader>fc", "<cmd>Telescope grep_string<cr>", desc = "Find word under cursor" },
      { "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", desc = "Document Symbols" },
    },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")

      telescope.setup({
        defaults = {
          prompt_prefix = " ",
          selection_caret = " ",
          path_display = { "smart" },
          mappings = {
            i = {
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
            },
          },
        },
        pickers = {
          find_files = {
            hidden = true,
          },
        },
      })

      -- Load fzf extension
      telescope.load_extension("fzf")
    end,
  },
-- LSP Configuration
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
      "onsails/lspkind.nvim",
    },
    config = function()
      -- Mason setup
      require("mason").setup({
        ui = {
          border = "rounded",
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗",
          },
        },
      })

      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls", "pyright", "ts_ls", "html", "cssls", "jsonls","astro"
        },
        automatic_installation = true,
      })

      -- Diagnostic configuration
      vim.diagnostic.config({
        virtual_text = { prefix = "●" },
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = { border = "rounded", source = "always" },
      })

      local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
      end

      -- ==========================================================
      --  CUSTOM TOGGLE: Intellisense (Space + t + i)
      -- ==========================================================
      vim.g.cmp_is_enabled = true -- Enabled by default

      vim.keymap.set("n", "<leader>ti", function()
        vim.g.cmp_is_enabled = not vim.g.cmp_is_enabled
        if vim.g.cmp_is_enabled then
          print("Intellisense Enabled")
        else
          require("cmp").abort() -- Close menu immediately
          print("Intellisense Disabled")
        end
      end, { desc = "Toggle Intellisense" })
      -- ==========================================================

      -- nvim-cmp setup
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      local lspkind = require("lspkind")

      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        -- CHECK THE TOGGLE VARIABLE HERE
        enabled = function()
          -- Always enable completion in command mode (:) even if disabled in code
          if vim.api.nvim_get_mode().mode == "c" then
            return true
          end
          return vim.g.cmp_is_enabled
        end,

        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp", priority = 1000 },
          { name = "luasnip", priority = 750 },
          { name = "buffer", priority = 500 },
          { name = "path", priority = 250 },
        }),
        formatting = {
          format = lspkind.cmp_format({
            mode = "symbol_text",
            maxwidth = 50,
            ellipsis_char = "...",
          }),
        },
      })

      -- Cmdline completions
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "path" },
          { name = "cmdline" },
        }),
      })

      cmp.setup.cmdline("/", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "buffer" },
        },
      })

      -- LSP servers setup
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      local function setup_lsp(server_name, extra_config)
        extra_config = extra_config or {}
        extra_config.capabilities = capabilities
        vim.lsp.config(server_name, extra_config)
        vim.lsp.enable(server_name)
      end

      setup_lsp("lua_ls", {
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
          },
        },
      })
      setup_lsp("pyright")
      setup_lsp("ts_ls")
      setup_lsp("html")
      setup_lsp("cssls")
      setup_lsp("jsonls")
      setup_lsp("clangd")
      setup_lsp("astro")
    end,
  },

  -- Git integration
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("gitsigns").setup({
        signs = {
          add = { text = "│" },
          change = { text = "│" },
          delete = { text = "_" },
          topdelete = { text = "‾" },
          changedelete = { text = "~" },
          untracked = { text = "┆" },
        },
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          local map = vim.keymap.set

          -- Navigation
          map("n", "]c", function()
            if vim.wo.diff then return "]c" end
            vim.schedule(function() gs.next_hunk() end)
            return "<Ignore>"
          end, { expr = true, buffer = bufnr, desc = "Next git hunk" })

          map("n", "[c", function()
            if vim.wo.diff then return "[c" end
            vim.schedule(function() gs.prev_hunk() end)
            return "<Ignore>"
          end, { expr = true, buffer = bufnr, desc = "Previous git hunk" })

          -- Actions
          map("n", "<leader>gp", gs.preview_hunk, { buffer = bufnr, desc = "Preview hunk" })
          map("n", "<leader>gb", gs.blame_line, { buffer = bufnr, desc = "Blame line" })
        end,
      })
    end,
  },

  -- File explorer
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = { "NvimTreeToggle", "NvimTreeFocus" },
    config = function()
      require("nvim-tree").setup({
        disable_netrw = true,
        hijack_cursor = true,
        sync_root_with_cwd = true,
        view = {
          width = 35,
          preserve_window_proportions = true,
        },
        renderer = {
          root_folder_label = false,
          highlight_git = true,
          indent_markers = { enable = true },
          icons = {
            glyphs = {
              default = "",
              folder = {
                default = "",
                open = "",
                empty = "",
                empty_open = "",
              },
              git = {
                unstaged = "✗",
                staged = "✓",
                unmerged = "",
                renamed = "➜",
                untracked = "★",
                deleted = "",
                ignored = "◌",
              },
            },
          },
        },
        filters = {
          dotfiles = false,
          custom = { "^.git$" },
        },
      })
    end,
  },

  -- Commenting
  {
    "numToStr/Comment.nvim",
    keys = {
      { "gc", mode = { "n", "v" }, desc = "Comment toggle linewise" },
      { "gb", mode = { "n", "v" }, desc = "Comment toggle blockwise" },
    },
    config = true,
  },

  -- Auto pairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      local autopairs = require("nvim-autopairs")
      autopairs.setup({
        check_ts = true,
        fast_wrap = {},
      })

      -- Integration with nvim-cmp
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      local cmp = require("cmp")
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end,
  },

  -- Bufferline
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    dependencies = "nvim-tree/nvim-web-devicons",
    keys = {
      { "<Tab>", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
      { "<S-Tab>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev buffer" },
      { "<leader>bd", "<cmd>bdelete<cr>", desc = "Close buffer" },
      { "<leader>bo", "<cmd>BufferLineCloseOthers<cr>", desc = "Close other buffers" },
      { "<leader>br", "<cmd>BufferLineCloseRight<cr>", desc = "Close buffers to right" },
      { "<leader>bl", "<cmd>BufferLineCloseLeft<cr>", desc = "Close buffers to left" },
    },
    config = function()
      require("bufferline").setup({
        options = {
          mode = "buffers",
          diagnostics = "nvim_lsp",
          show_buffer_close_icons = true,
          show_close_icon = false,
          separator_style = "slant",
          offsets = {
            {
              filetype = "NvimTree",
              text = "File Explorer",
              text_align = "center",
              separator = true,
            },
          },
        },
      })
    end,
  },

  -- Status line
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "catppuccin",
          component_separators = { left = "|", right = "|" },
          section_separators = { left = "", right = "" },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { { "filename", path = 1 } },
          lualine_x = { "encoding", "fileformat", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
      })
    end,
  },

  -- Terminal
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = {
      { "<C-\\>", desc = "Toggle terminal" },
      { "<leader>tf", desc = "Toggle floating terminal" },
      { "<leader>tv", desc = "Toggle vertical terminal" },
      { "<leader>th", desc = "Toggle horizontal terminal" },
    },
    config = function()
      require("toggleterm").setup({
        size = function(term)
          if term.direction == "horizontal" then
            return 15
          elseif term.direction == "vertical" then
            return vim.o.columns * 0.4
          end
        end,
        open_mapping = [[<C-\>]],
        shade_terminals = true,
        start_in_insert = true,
        persist_size = true,
        direction = "horizontal",
        close_on_exit = true,
        shell = vim.o.shell,
        float_opts = {
          border = "curved",
        },
      })

      local Terminal = require("toggleterm.terminal").Terminal

      -- Floating terminal
      local float_term = Terminal:new({ direction = "float" })
      vim.keymap.set("n", "<leader>tf", function()
        float_term:toggle()
      end, { desc = "Toggle floating terminal" })

      -- Vertical terminal
      local vert_term = Terminal:new({ direction = "vertical" })
      vim.keymap.set("n", "<leader>tv", function()
        vert_term:toggle()
      end, { desc = "Toggle vertical terminal" })

      -- Horizontal terminal
      local hori_term = Terminal:new({ direction = "horizontal" })
      vim.keymap.set("n", "<leader>th", function()
        hori_term:toggle()
      end, { desc = "Toggle horizontal terminal" })
    end,
  },

  -- Which-key for keybinding hints
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      local wk = require("which-key")
      wk.setup({
        win = {
          border = "rounded",
        },
      })

      -- Register key group descriptions
      wk.add({
        { "<leader>f", group = "Find" },
        { "<leader>b", group = "Buffer" },
        { "<leader>g", group = "Git" },
        { "<leader>s", group = "Split" },
        { "<leader>t", group = "Terminal/Toggle" },
        { "<leader>c", group = "Code" },
      })
    end,
  },

  -- Indent guides
  {
    "lukas-reineke/indent-blankline.nvim",
    event = { "BufReadPost", "BufNewFile" },
    main = "ibl",
    config = function()
      require("ibl").setup({
        indent = {
          char = "│",
        },
        scope = {
          show_start = false,
          show_end = false,
        },
      })
    end,
  },
}
