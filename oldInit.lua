-- ~/.config/nvim/init.lua

-- 🔹 Leader key (must be set *before* keymaps!)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- 🔹 Basic settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.clipboard = "unnamedplus" -- use system clipboard

-- 🔹 Bootstrap lazy.nvim if it’s not installed
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
require("lazy").setup("plugins")

-- 🔹 Keymaps helper
local map = vim.keymap.set

-- 🔹 File explorer
map("n", "<leader>e", ":Ex<CR>", { desc = "File Explorer" })

-- 🔹 Split navigation (hjkl)
map("n", "<leader>h", "<C-w>h", { desc = "Move Left" })
map("n", "<leader>j", "<C-w>j", { desc = "Move Down" })
map("n", "<leader>k", "<C-w>k", { desc = "Move Up" })
map("n", "<leader>l", "<C-w>l", { desc = "Move Right" })

-- 🔹 Split management
map("n", "<leader>sv", ":vsplit<CR>", { desc = "Vertical Split" })
map("n", "<leader>sh", ":split<CR>",  { desc = "Horizontal Split" })
map("n", "<leader>sc", ":close<CR>",  { desc = "Close Split" })
map("n", "<leader>so", ":only<CR>",   { desc = "Close Other Splits" })

-- 🔹 Blank splits / buffers
map("n", "<leader>svb", ":vnew<CR>", { desc = "Vertical Blank Split" })
map("n", "<leader>shb", ":new<CR>",  { desc = "Horizontal Blank Split" })
map("n", "<leader>b",   ":enew<CR>", { desc = "New Empty Buffer" })
