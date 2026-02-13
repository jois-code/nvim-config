-- lua/plugins/ui.lua
return {

    -- ── Colorscheme ─────────────────────────────────────────────────────────
    {
        "folke/tokyonight.nvim",
        name = "tokyonight",
        priority = 1000,
        config = function()
            require("tokyonight").setup({
                style         = "moon", -- night | storm | moon | day
                transparent   = false,
                term_colors   = true,
                dim_inactive  = true,
                styles        = {
                    comments  = { italic = true },
                    keywords  = { italic = true },
                    functions = {},
                    variables = {},
                    sidebars  = "dark",
                    floats    = "dark",
                },
                on_highlights = function(hl, c)
                    -- Crisper current line number
                    hl.CursorLineNr = { fg = c.orange, bold = true }
                    -- Slightly brighter indent guides
                    hl.IblIndent = { fg = c.dark3 }
                end,
            })
            vim.cmd.colorscheme("tokyonight")
        end,
    },

    -- ── Dashboard ───────────────────────────────────────────────────────────
    {
        "nvimdev/dashboard-nvim",
        event = "VimEnter",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("dashboard").setup({
                theme = "doom",
                config = {
                    header = {
                        "",
                        "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗  ",
                        "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║  ",
                        "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║  ",
                        "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║  ",
                        "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║  ",
                        "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝  ",
                        "",
                    },
                    center = {
                        { icon = "  ", key = "f", desc = "Find File", action = "Telescope find_files" },
                        { icon = "  ", key = "r", desc = "Recent Files", action = "Telescope oldfiles" },
                        { icon = "  ", key = "g", desc = "Live Grep", action = "Telescope live_grep" },
                        { icon = "  ", key = "e", desc = "File Explorer", action = "NvimTreeToggle" },
                        { icon = "  ", key = "n", desc = "New File", action = "enew" },
                        { icon = "󰒲  ", key = "l", desc = "Lazy", action = "Lazy" },
                        { icon = "  ", key = "q", desc = "Quit", action = "qa" },
                    },
                    footer = function()
                        local stats = require("lazy").stats()
                        return { "⚡ " .. stats.loaded .. "/" .. stats.count .. " plugins loaded" }
                    end,
                },
            })
        end,
    },

    -- ── Bufferline ──────────────────────────────────────────────────────────
    {
        "akinsho/bufferline.nvim",
        event = "VeryLazy",
        dependencies = "nvim-tree/nvim-web-devicons",
        keys = {
            { "<Tab>",      "<cmd>BufferLineCycleNext<cr>",   desc = "Next buffer" },
            { "<S-Tab>",    "<cmd>BufferLineCyclePrev<cr>",   desc = "Prev buffer" },
            { "<leader>bd", "<cmd>bdelete<cr>",               desc = "Close buffer" },
            { "<leader>bo", "<cmd>BufferLineCloseOthers<cr>", desc = "Close other buffers" },
            { "<leader>br", "<cmd>BufferLineCloseRight<cr>",  desc = "Close buffers to right" },
            { "<leader>bl", "<cmd>BufferLineCloseLeft<cr>",   desc = "Close buffers to left" },
            { "<leader>bp", "<cmd>BufferLineTogglePin<cr>",   desc = "Pin/Unpin buffer" },
        },
        config = function()
            require("bufferline").setup({
                options = {
                    mode = "buffers",
                    diagnostics = "nvim_lsp",
                    diagnostics_indicator = function(_, _, diag)
                        local icons = { error = " ", warning = " " }
                        local ret = (diag.error and icons.error .. diag.error or "")
                            .. (diag.warning and icons.warning .. diag.warning or "")
                        return vim.trim(ret)
                    end,
                    show_buffer_close_icons = true,
                    show_close_icon = false,
                    separator_style = "slant",
                    always_show_bufferline = false,
                    offsets = {
                        { filetype = "NvimTree", text = "File Explorer", text_align = "center", separator = true },
                    },
                },
            })
        end,
    },

    -- ── Status line ─────────────────────────────────────────────────────────
    {
        "nvim-lualine/lualine.nvim",
        event = "VeryLazy",
        dependencies = { "nvim-tree/nvim-web-devicons", "folke/tokyonight.nvim" },
        config = function()
            local function lsp_client_names()
                local clients = vim.lsp.get_clients({ bufnr = 0 })
                if #clients == 0 then return "" end
                local names = {}
                for _, c in ipairs(clients) do
                    table.insert(names, c.name)
                end
                return " " .. table.concat(names, ", ")
            end

            require("lualine").setup({
                options = {
                    theme                = "tokyonight",
                    component_separators = { left = "│", right = "│" },
                    section_separators   = { left = "", right = "" },
                    globalstatus         = true, -- single statusline for all splits
                },
                sections = {
                    lualine_a = { "mode" },
                    lualine_b = { "branch", "diff", "diagnostics" },
                    lualine_c = { { "filename", path = 1 } },
                    lualine_x = { lsp_client_names, "encoding", "fileformat", "filetype" },
                    lualine_y = { "progress" },
                    lualine_z = { "location" },
                },
                extensions = { "nvim-tree", "toggleterm", "quickfix" },
            })
        end,
    },

    -- ── Indent guides ───────────────────────────────────────────────────────
    {
        "lukas-reineke/indent-blankline.nvim",
        event = { "BufReadPost", "BufNewFile" },
        main = "ibl",
        config = function()
            require("ibl").setup({
                indent = { char = "│" },
                scope  = { show_start = false, show_end = false },
            })
        end,
    },

    -- ── Notifications & UI improvements ─────────────────────────────────────
    {
        "folke/noice.nvim",
        event = "VeryLazy",
        dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
        config = function()
            require("noice").setup({
                lsp = {
                    override = {
                        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                        ["vim.lsp.util.stylize_markdown"] = true,
                        ["cmp.entry.get_documentation"] = true,
                    },
                    progress = { enabled = true },
                },
                presets = {
                    bottom_search         = true,
                    command_palette       = true,
                    long_message_to_split = true,
                    inc_rename            = false,
                },
            })
        end,
    },

    -- ── Colorizer (show hex colours inline) ─────────────────────────────────
    {
        "NvChad/nvim-colorizer.lua",
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            require("colorizer").setup({
                filetypes = { "*" },
                user_default_options = { mode = "background", tailwind = true },
            })
        end,
    },
}
