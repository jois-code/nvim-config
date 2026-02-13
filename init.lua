-- ~/.config/nvim/init.lua

-- 🔹 Leader key (must be set *before* lazy.nvim!)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- 🔹 Disable netrw early (nvim-tree replaces it)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- ============================================================
-- OPTIONS
-- ============================================================
local opt = vim.opt

-- UI
opt.termguicolors = true
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.signcolumn = "yes"
opt.wrap = false
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.showmode = false          -- lualine shows mode instead
opt.cmdheight = 1
opt.pumheight = 10            -- max items in completion menu
opt.splitright = true
opt.splitbelow = true

-- Editing
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true
opt.clipboard = "unnamedplus"
opt.undofile = true
opt.swapfile = false
opt.backup = false

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = false
opt.incsearch = true

-- Performance
opt.updatetime = 200
opt.timeoutlen = 300
opt.lazyredraw = false        -- off: better for macros but smooth UI

-- Folds (using treesitter)
opt.foldmethod = "expr"
opt.foldexpr = "nvim_treesitter#foldexpr()"
opt.foldenable = false        -- open all folds by default

-- ============================================================
-- BOOTSTRAP lazy.nvim
-- ============================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins", {
  ui = { border = "rounded" },
  checker = { enabled = true, notify = false }, -- auto-check updates silently
  change_detection = { notify = false },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin",
        "netrwPlugin", "netrw", "netrwSettings",
      },
    },
  },
})

-- ============================================================
-- KEYMAPS
-- ============================================================
local map = vim.keymap.set

-- Better escape
map("i", "jk", "<ESC>", { desc = "Exit insert mode" })
map("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Clear search highlight
map("n", "<Esc>", ":noh<CR>", { desc = "Clear highlights" })

-- File explorer
map("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "File Explorer" })

-- Split navigation (Ctrl + hjkl, works in terminal too)
map({ "n", "t" }, "<C-h>", "<C-w>h", { desc = "Move Left" })
map({ "n", "t" }, "<C-j>", "<C-w>j", { desc = "Move Down" })
map({ "n", "t" }, "<C-k>", "<C-w>k", { desc = "Move Up" })
map({ "n", "t" }, "<C-l>", "<C-w>l", { desc = "Move Right" })

-- Split management
map("n", "<leader>w",  ":w<CR>",      { desc = "Save file" })
map("n", "<leader>q",  ":q<CR>",      { desc = "Quit" })
map("n", "<leader>sv", ":vsplit<CR>", { desc = "Vertical Split" })
map("n", "<leader>sh", ":split<CR>",  { desc = "Horizontal Split" })
map("n", "<leader>sc", ":close<CR>",  { desc = "Close Split" })
map("n", "<leader>so", ":only<CR>",   { desc = "Close Other Splits" })
map("n", "<leader>se", "<C-w>=",      { desc = "Equalize Splits" })

-- Resize splits with arrow keys
map("n", "<C-Up>",    ":resize +2<CR>",           { desc = "Increase height" })
map("n", "<C-Down>",  ":resize -2<CR>",            { desc = "Decrease height" })
map("n", "<C-Left>",  ":vertical resize -2<CR>",   { desc = "Decrease width" })
map("n", "<C-Right>", ":vertical resize +2<CR>",   { desc = "Increase width" })

-- Better indenting (stay in visual mode)
map("v", "<", "<gv", { desc = "Indent left" })
map("v", ">", ">gv", { desc = "Indent right" })

-- Move lines (Alt + jk)
map("n", "<A-j>", ":m .+1<CR>==",        { desc = "Move line down" })
map("n", "<A-k>", ":m .-2<CR>==",        { desc = "Move line up" })
map("v", "<A-j>", ":m '>+1<CR>gv=gv",   { desc = "Move selection down" })
map("v", "<A-k>", ":m '<-2<CR>gv=gv",   { desc = "Move selection up" })

-- Better paste (don't overwrite register)
map("v", "p", '"_dP', { desc = "Paste without yanking" })

-- Select all
map("n", "<C-a>", "ggVG", { desc = "Select all" })

-- Blank splits / new buffers
map("n", "<leader>vb", ":vnew<CR>",  { desc = "Vertical Blank Split" })
map("n", "<leader>hb", ":new<CR>",   { desc = "Horizontal Blank Split" })
map("n", "<leader>bn", ":enew<CR>",  { desc = "New Empty Buffer" })

-- Quick fix list navigation
map("n", "<leader>xo", ":copen<CR>",  { desc = "Open quickfix" })
map("n", "<leader>xc", ":cclose<CR>", { desc = "Close quickfix" })
map("n", "]q", ":cnext<CR>",          { desc = "Next quickfix item" })
map("n", "[q", ":cprev<CR>",          { desc = "Prev quickfix item" })

-- ============================================================
-- LSP KEYMAPS (attached per buffer)
-- ============================================================
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    local opts = function(desc)
      return { buffer = ev.buf, desc = desc }
    end
    map("n", "gd",         vim.lsp.buf.definition,     opts("Go to definition"))
    map("n", "gD",         vim.lsp.buf.declaration,    opts("Go to declaration"))
    map("n", "gR",         vim.lsp.buf.references,     opts("Show references"))
    map("n", "gi",         vim.lsp.buf.implementation, opts("Go to implementation"))
    map("n", "gt",         vim.lsp.buf.type_definition,opts("Go to type definition"))
    map("n", "K",          vim.lsp.buf.hover,          opts("Hover documentation"))
    map("n", "<leader>rn", vim.lsp.buf.rename,         opts("Rename symbol"))
    map("n", "<leader>ca", vim.lsp.buf.code_action,    opts("Code action"))
    map("n", "<leader>d",  vim.diagnostic.open_float,  opts("Show diagnostics"))
    map("n", "[d",         vim.diagnostic.goto_prev,   opts("Previous diagnostic"))
    map("n", "]d",         vim.diagnostic.goto_next,   opts("Next diagnostic"))
    map("n", "<leader>lf", function() vim.lsp.buf.format({ async = true }) end, opts("Format file"))
  end,
})

-- ============================================================
-- AUTOCOMMANDS
-- ============================================================
local augroup  = vim.api.nvim_create_augroup
local autocmd  = vim.api.nvim_create_autocmd

-- Highlight yanked text briefly
autocmd("TextYankPost", {
  group = augroup("highlight_yank", { clear = true }),
  callback = function() vim.highlight.on_yank({ timeout = 200 }) end,
})

-- Remove trailing whitespace on save
autocmd("BufWritePre", {
  group = augroup("trim_whitespace", { clear = true }),
  pattern = "*",
  callback = function()
    local save = vim.fn.getpos(".")
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.setpos(".", save)
  end,
})

-- Restore cursor position when reopening a file
autocmd("BufReadPost", {
  group = augroup("restore_cursor", { clear = true }),
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Auto-resize splits when window is resized
autocmd("VimResized", {
  group = augroup("resize_splits", { clear = true }),
  callback = function() vim.cmd("tabdo wincmd =") end,
})

-- Close certain windows with just 'q'
autocmd("FileType", {
  group = augroup("close_with_q", { clear = true }),
  pattern = { "help", "qf", "man", "checkhealth", "lspinfo" },
  callback = function(ev)
    map("n", "q", "<cmd>close<CR>", { buffer = ev.buf, silent = true })
  end,
})
