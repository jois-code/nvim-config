-- lua/plugins/editor.lua
return {

  -- ── Treesitter ───────────────────────────────────────────────────────────
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    -- Load eagerly so parsers are ready before any buffer opens
    lazy = false,
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    config = function()
      local ok, configs = pcall(require, "nvim-treesitter.configs")
      if not ok then return end
      configs.setup({
        ensure_installed = {
          "lua", "vim", "vimdoc",
          "python",
          "c", "cpp",
          "javascript", "typescript", "tsx",
          "html", "css", "json", "jsonc",
          "markdown", "markdown_inline",
          "bash", "yaml", "toml",
          "astro",
        },
        auto_install = true,
        highlight   = { enable = true },
        indent      = { enable = true },
        incremental_selection = {
          enable  = true,
          keymaps = {
            init_selection   = "<C-space>",
            node_incremental = "<C-space>",
            scope_incremental = false,
            node_decremental = "<bs>",
          },
        },
        textobjects = {
          select = {
            enable    = true,
            lookahead = true,
            keymaps   = {
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              ["ic"] = "@class.inner",
              ["aa"] = "@parameter.outer",
              ["ia"] = "@parameter.inner",
            },
          },
          move = {
            enable              = true,
            set_jumps           = true,
            goto_next_start     = { ["]f"] = "@function.outer", ["]c"] = "@class.outer" },
            goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer" },
          },
        },
      })
    end,
  },

  -- ── Telescope ───────────────────────────────────────────────────────────
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      "nvim-telescope/telescope-ui-select.nvim",  -- use telescope for vim.ui.select
    },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>",          desc = "Find Files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>",           desc = "Live Grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>",             desc = "Find Buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>",           desc = "Find Help" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>",            desc = "Recent Files" },
      { "<leader>fc", "<cmd>Telescope grep_string<cr>",         desc = "Find Word Under Cursor" },
      { "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>",desc = "Document Symbols" },
      { "<leader>fd", "<cmd>Telescope diagnostics<cr>",         desc = "Diagnostics" },
      { "<leader>fk", "<cmd>Telescope keymaps<cr>",             desc = "Keymaps" },
    },
    config = function()
      local telescope = require("telescope")
      local actions   = require("telescope.actions")

      telescope.setup({
        defaults = {
          prompt_prefix  = "   ",
          selection_caret = "  ",
          path_display   = { "smart" },
          file_ignore_patterns = { "node_modules", ".git/", "__pycache__", "%.o", "%.a" },
          mappings = {
            i = {
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
              ["<Esc>"] = actions.close,
            },
          },
        },
        pickers = {
          find_files = { hidden = true },
          live_grep  = { additional_args = { "--hidden" } },
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter    = true,
            case_mode               = "smart_case",
          },
          ["ui-select"] = { require("telescope.themes").get_dropdown({}) },
        },
      })

      telescope.load_extension("fzf")
      telescope.load_extension("ui-select")
    end,
  },

  -- ── Commenting ──────────────────────────────────────────────────────────
  {
    "numToStr/Comment.nvim",
    keys = {
      { "gc", mode = { "n", "v" }, desc = "Comment toggle linewise" },
      { "gb", mode = { "n", "v" }, desc = "Comment toggle blockwise" },
    },
    config = true,
  },

  -- ── Auto pairs ──────────────────────────────────────────────────────────
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({ check_ts = true, fast_wrap = {} })
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      require("cmp").event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end,
  },

  -- ── Surround ────────────────────────────────────────────────────────────
  -- ys<motion><char>  add surround
  -- ds<char>          delete surround
  -- cs<old><new>      change surround
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    config = true,
  },

  -- ── Flash (better f/t/s motion) ─────────────────────────────────────────
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    keys = {
      { "s",     mode = { "n", "x", "o" }, function() require("flash").jump() end,              desc = "Flash jump" },
      { "S",     mode = { "n", "x", "o" }, function() require("flash").treesitter() end,        desc = "Flash treesitter" },
      { "r",     mode = "o",               function() require("flash").remote() end,            desc = "Remote flash" },
      { "<c-s>", mode = { "c" },           function() require("flash").toggle() end,            desc = "Toggle flash search" },
    },
  },

  -- ── Which-key ───────────────────────────────────────────────────────────
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      local wk = require("which-key")
      wk.setup({ win = { border = "rounded" } })
      wk.add({
        { "<leader>f",  group = "Find/Telescope" },
        { "<leader>b",  group = "Buffer" },
        { "<leader>g",  group = "Git" },
        { "<leader>s",  group = "Split" },
        { "<leader>t",  group = "Terminal/Toggle" },
        { "<leader>l",  group = "LSP" },
        { "<leader>x",  group = "Quickfix" },
      })
    end,
  },

  -- ── File explorer ────────────────────────────────────────────────────────
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = { "NvimTreeToggle", "NvimTreeFocus" },
    config = function()
      require("nvim-tree").setup({
        disable_netrw       = true,
        hijack_cursor       = true,
        sync_root_with_cwd  = true,
        update_focused_file = { enable = true },
        view = {
          width = 35,
          preserve_window_proportions = true,
        },
        renderer = {
          root_folder_label = false,
          highlight_git     = true,
          indent_markers    = { enable = true },
          icons = {
            glyphs = {
              default = "",
              folder  = { default = "", open = "", empty = "", empty_open = "" },
              git     = { unstaged = "✗", staged = "✓", unmerged = "", renamed = "➜", untracked = "★", deleted = "", ignored = "◌" },
            },
          },
        },
        filters = { dotfiles = false, custom = { "^.git$" } },
        actions = { open_file = { quit_on_open = false } },
      })
    end,
  },

  -- ── Terminal ─────────────────────────────────────────────────────────────
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = {
      { "<C-\\>",      desc = "Toggle terminal" },
      { "<leader>tf",  desc = "Floating terminal" },
      { "<leader>tv",  desc = "Vertical terminal" },
      { "<leader>th",  desc = "Horizontal terminal" },
      { "<leader>tg",  desc = "Lazygit" },
    },
    config = function()
      require("toggleterm").setup({
        size = function(term)
          if term.direction == "horizontal" then return 15
          elseif term.direction == "vertical" then return vim.o.columns * 0.4
          end
        end,
        open_mapping    = [[<C-\>]],
        shade_terminals = true,
        start_in_insert = true,
        persist_size    = true,
        direction       = "horizontal",
        close_on_exit   = true,
        shell           = vim.o.shell,
        float_opts      = { border = "curved" },
      })

      local Terminal = require("toggleterm.terminal").Terminal
      local float_term = Terminal:new({ direction = "float" })
      local vert_term  = Terminal:new({ direction = "vertical" })
      local hori_term  = Terminal:new({ direction = "horizontal" })
      local lazygit    = Terminal:new({ cmd = "lazygit", direction = "float", hidden = true })

      vim.keymap.set("n", "<leader>tf", function() float_term:toggle() end, { desc = "Floating terminal" })
      vim.keymap.set("n", "<leader>tv", function() vert_term:toggle()  end, { desc = "Vertical terminal" })
      vim.keymap.set("n", "<leader>th", function() hori_term:toggle()  end, { desc = "Horizontal terminal" })
      vim.keymap.set("n", "<leader>tg", function() lazygit:toggle()    end, { desc = "Lazygit" })
    end,
  },

  -- ── Todo comments ────────────────────────────────────────────────────────
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ft", "<cmd>TodoTelescope<cr>", desc = "Find TODOs" },
      { "]t",  function() require("todo-comments").jump_next() end, desc = "Next todo" },
      { "[t",  function() require("todo-comments").jump_prev() end, desc = "Prev todo" },
    },
    config = true,
  },

  -- ── Trouble (better diagnostics list) ───────────────────────────────────
  {
    "folke/trouble.nvim",
    cmd  = "Trouble",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>",                    desc = "Diagnostics (Trouble)" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",      desc = "Buffer diagnostics" },
      { "<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>",           desc = "Symbols (Trouble)" },
      { "<leader>xl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "LSP Definitions (Trouble)" },
    },
    config = true,
  },
}
