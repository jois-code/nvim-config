-- ~/.config/nvim/init.lua

-- 🔹 Leader key (must be set *before* keymaps!)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- 🔹 Basic settings
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.clipboard = "unnamedplus"

-- 🔹 Enhanced editor options
vim.opt.termguicolors = true        -- enable 24-bit RGB colors
vim.opt.undofile = true              -- persistent undo
vim.opt.ignorecase = true            -- case insensitive search
vim.opt.smartcase = true             -- unless uppercase is used
vim.opt.hlsearch = false             -- don't highlight all matches
vim.opt.incsearch = true             -- incremental search
vim.opt.scrolloff = 8                -- keep 8 lines above/below cursor
vim.opt.sidescrolloff = 8            -- keep 8 columns left/right of cursor
vim.opt.updatetime = 250             -- faster completion
vim.opt.timeoutlen = 300             -- faster key sequence completion
vim.opt.cursorline = true            -- highlight current line
vim.opt.signcolumn = "yes"           -- always show sign column
vim.opt.wrap = false                 -- disable line wrap

-- 🔹 Bootstrap lazy.nvim if it's not installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- 🔹 Setup lazy.nvim
require("lazy").setup("plugins", {
  ui = {
    border = "rounded",
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})

-- 🔹 Keymaps helper
local map = vim.keymap.set

-- 🔹 Better escape
map("i", "jk", "<ESC>", { desc = "Exit insert mode" })

-- 🔹 Clear search highlight
map("n", "<Esc>", ":noh<CR>", { desc = "Clear highlights" })

-- 🔹 File explorer
map("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "File Explorer" })

-- 🔹 Split navigation (hjkl)
map("n", "<C-h>", "<C-w>h", { desc = "Move Left" })
map("n", "<C-j>", "<C-w>j", { desc = "Move Down" })
map("n", "<C-k>", "<C-w>k", { desc = "Move Up" })
map("n", "<C-l>", "<C-w>l", { desc = "Move Right" })

-- 🔹 Split management
map("n", "<leader>w", ":w<CR>", { desc = "Save file" })
map("n", "<leader>q", ":q<CR>", { desc = "Quit" })
map("n", "<leader>sv", ":vsplit<CR>", { desc = "Vertical Split" })
map("n", "<leader>sh", ":split<CR>", { desc = "Horizontal Split" })
map("n", "<leader>sc", ":close<CR>", { desc = "Close Split" })
map("n", "<leader>so", ":only<CR>", { desc = "Close Other Splits" })
map("n", "<leader>se", "<C-w>=", { desc = "Equalize splits" })

-- 🔹 Resize splits
map("n", "<C-Up>", ":resize +2<CR>", { desc = "Increase height" })
map("n", "<C-Down>", ":resize -2<CR>", { desc = "Decrease height" })
map("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Decrease width" })
map("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Increase width" })

-- 🔹 Better indenting
map("v", "<", "<gv", { desc = "Indent left" })
map("v", ">", ">gv", { desc = "Indent right" })

-- 🔹 Move lines
map("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
map("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })
map("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- 🔹 Better paste
map("v", "p", '"_dP', { desc = "Paste without yanking" })

-- 🔹 Select all
map("n", "<C-a>", "ggVG", { desc = "Select all" })

-- 🔹 Blank splits / buffers
map("n", "<leader>vb", ":vnew<CR>", { desc = "Vertical Blank Split" })
map("n", "<leader>hb", ":new<CR>", { desc = "Horizontal Blank Split" })
map("n", "<leader>bn", ":enew<CR>", { desc = "New Empty Buffer" })

-- 🔹 LSP keymaps (will be set when LSP attaches)
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    local opts = { buffer = ev.buf }
    map("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Go to definition" }))
    map("n", "gD", vim.lsp.buf.declaration, vim.tbl_extend("force", opts, { desc = "Go to declaration" }))
    map("n", "gR", vim.lsp.buf.references, vim.tbl_extend("force", opts, { desc = "Show references" }))
    map("n", "gi", vim.lsp.buf.implementation, vim.tbl_extend("force", opts, { desc = "Go to implementation" }))
    map("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Hover documentation" }))
    map("n", "<leader>rn", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename symbol" }))
    map("n", "<leader>ca", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "Code action" }))
    map("n", "<leader>d", vim.diagnostic.open_float, vim.tbl_extend("force", opts, { desc = "Show diagnostics" }))
    map("n", "[d", vim.diagnostic.goto_prev, vim.tbl_extend("force", opts, { desc = "Previous diagnostic" }))
    map("n", "]d", vim.diagnostic.goto_next, vim.tbl_extend("force", opts, { desc = "Next diagnostic" }))
  end,
})

-- 🔹 Autocommands
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Highlight on yank
autocmd("TextYankPost", {
  group = augroup("highlight_yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank({ timeout = 200 })
  end,
})

-- Remove trailing whitespace on save
autocmd("BufWritePre", {
  group = augroup("trim_whitespace", { clear = true }),
  pattern = "*",
  callback = function()
    local save_cursor = vim.fn.getpos(".")
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.setpos(".", save_cursor)
  end,
})

