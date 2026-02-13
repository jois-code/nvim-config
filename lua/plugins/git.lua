-- lua/plugins/git.lua
return {

  -- ── Gitsigns (inline hunk indicators + blame) ───────────────────────────
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("gitsigns").setup({
        signs = {
          add          = { text = "▎" },
          change       = { text = "▎" },
          delete       = { text = "" },
          topdelete    = { text = "" },
          changedelete = { text = "▎" },
          untracked    = { text = "▎" },
        },
        current_line_blame = false, -- toggle with <leader>gb
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = "eol",
          delay = 500,
        },
        on_attach = function(bufnr)
          local gs  = package.loaded.gitsigns
          local map = function(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          -- Navigation between hunks
          map("n", "]h", function()
            if vim.wo.diff then return "]h" end
            vim.schedule(function() gs.next_hunk() end)
            return "<Ignore>"
          end, { expr = true, desc = "Next git hunk" })

          map("n", "[h", function()
            if vim.wo.diff then return "[h" end
            vim.schedule(function() gs.prev_hunk() end)
            return "<Ignore>"
          end, { expr = true, desc = "Prev git hunk" })

          -- Actions
          map("n", "<leader>gp",  gs.preview_hunk,                       { desc = "Preview hunk" })
          map("n", "<leader>gs",  gs.stage_hunk,                         { desc = "Stage hunk" })
          map("n", "<leader>gr",  gs.reset_hunk,                         { desc = "Reset hunk" })
          map("v", "<leader>gs",  function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, { desc = "Stage selected hunk" })
          map("n", "<leader>gS",  gs.stage_buffer,                       { desc = "Stage buffer" })
          map("n", "<leader>gu",  gs.undo_stage_hunk,                    { desc = "Undo stage hunk" })
          map("n", "<leader>gR",  gs.reset_buffer,                       { desc = "Reset buffer" })
          map("n", "<leader>gb",  gs.toggle_current_line_blame,          { desc = "Toggle blame" })
          map("n", "<leader>gd",  gs.diffthis,                           { desc = "Diff this" })
          map("n", "<leader>gD",  function() gs.diffthis("~") end,       { desc = "Diff against last commit" })

          -- Text objects for hunks
          map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { desc = "Select git hunk" })
        end,
      })
    end,
  },

  -- ── Diffview (full-screen diff / file history viewer) ───────────────────
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>gv",  "<cmd>DiffviewOpen<cr>",           desc = "Diffview open" },
      { "<leader>gV",  "<cmd>DiffviewClose<cr>",          desc = "Diffview close" },
      { "<leader>gh",  "<cmd>DiffviewFileHistory %<cr>",  desc = "File history (current)" },
      { "<leader>gH",  "<cmd>DiffviewFileHistory<cr>",    desc = "File history (all)" },
    },
    config = true,
  },
}
