return {
    -- Treesitter: better syntax highlighting
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter.configs").setup {
                highlight = {enable = true},
                indent = {enable = true}
            }
        end
    },
    -- Telescope: fuzzy finder
    {
        "nvim-telescope/telescope.nvim",
        dependencies = {"nvim-lua/plenary.nvim"},
        config = function()
            local builtin = require("telescope.builtin")
            vim.keymap.set("n", "<leader>ff", builtin.find_files, {desc = "Find Files"})
            vim.keymap.set("n", "<leader>fg", builtin.live_grep, {desc = "Live Grep"})
            vim.keymap.set("n", "<leader>fb", builtin.buffers, {desc = "Find Buffers"})
            vim.keymap.set("n", "<leader>fh", builtin.help_tags, {desc = "Find Help"})
        end
    },
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim", -- LSP server installer
            "williamboman/mason-lspconfig.nvim",
            -- mason <-> lspconfig bridge
            "hrsh7th/nvim-cmp", -- completion engine
            "hrsh7th/cmp-nvim-lsp", -- LSP source
            "hrsh7th/cmp-buffer", -- buffer source
            "hrsh7th/cmp-path", -- path completions
            "hrsh7th/cmp-cmdline", -- cmdline completions
            "L3MON4D3/LuaSnip", -- snippets engine
            "saadparwaiz1/cmp_luasnip", -- snippets source
            "onsails/lspkind.nvim" -- (optional) VSCode-like pictograms
        },
        config = function()
            -- Mason setup
            require("mason").setup()
            require("mason-lspconfig").setup {
                ensure_installed = {"lua_ls", "pyright", "ts_ls"} -- add more servers
            }

            -- nvim-cmp setup
            local cmp = require("cmp")
            local luasnip = require("luasnip")
            local lspkind = require("lspkind")
            local cmp_enabled = true

            cmp.setup {
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end
                },
                mapping = cmp.mapping.preset.insert(
                    {
                        ["<C-Space>"] = cmp.mapping.complete(),
                        ["<C-e>"] = cmp.mapping.abort(),
                        ["<CR>"] = cmp.mapping.confirm {select = true},
                        ["<Tab>"] = cmp.mapping(
                            function(fallback)
                                if cmp.visible() then
                                    cmp.select_next_item()
                                elseif luasnip.expand_or_jumpable() then
                                    luasnip.expand_or_jump()
                                else
                                    fallback()
                                end
                            end,
                            {"i", "s"}
                        ),
                        ["<S-Tab>"] = cmp.mapping(
                            function(fallback)
                                if cmp.visible() then
                                    cmp.select_prev_item()
                                elseif luasnip.jumpable(-1) then
                                    luasnip.jump(-1)
                                else
                                    fallback()
                                end
                            end,
                            {"i", "s"}
                        )
                    }
                ),
                sources = cmp.config.sources(
                    {
                        {name = "nvim_lsp"},
                        {name = "luasnip"},
                        {name = "buffer"},
                        {name = "path"}
                    }
                ),
                formatting = {
                    format = lspkind.cmp_format({mode = "symbol_text", maxwidth = 50})
                },
                enabled = function()
                    return cmp_enabled
                end
            }

            vim.keymap.set(
                "n",
                "<leader>ti",
                function()
                    cmp_enabled = not cmp_enabled
                    if cmp_enabled then
                        print("🔮 IntelliSense enabled")
                    else
                        print("🚫 IntelliSense disabled")
                    end
                end,
                {desc = "Toggle IntelliSense"}
            )

            -- LSP servers setup
            local capabilities = require("cmp_nvim_lsp").default_capabilities()
            local lspconfig = require("lspconfig")

            -- Lua
            lspconfig.lua_ls.setup {
                capabilities = capabilities,
                settings = {
                    Lua = {
                        diagnostics = {globals = {"vim"}}
                    }
                }
            }

            -- Python
            lspconfig.pyright.setup {capabilities = capabilities}

            -- JavaScript / TypeScript
            lspconfig.ts_ls.setup {capabilities = capabilities}
        end
    },
    -- LSP & Autocompletion
    {"williamboman/mason.nvim", config = true},
    {"hrsh7th/nvim-cmp"},
    {"hrsh7th/cmp-nvim-lsp"},
    {"L3MON4D3/LuaSnip"},
    -- Git integration
    {"lewis6991/gitsigns.nvim", config = true},
    -- File explorer
    {
        "nvim-tree/nvim-tree.lua",
        dependencies = {"nvim-tree/nvim-web-devicons"}, -- icons recommended
        config = function()
            local api = require("nvim-tree.api")

            require("nvim-tree").setup {
                view = {width = 35}
            }

            -- Toggle file explorer
            vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", {desc = "File Explorer"})
        end
    },
    -- Commenting
    {
        "numToStr/Comment.nvim",
        config = function()
            require("Comment").setup()
        end
    },
    {
        "akinsho/bufferline.nvim",
        version = "*",
        dependencies = "nvim-tree/nvim-web-devicons",
        config = function()
            require("bufferline").setup {
                options = {
                    diagnostics = "nvim_lsp",
                    show_buffer_close_icons = true,
                    show_close_icon = false,
                    separator_style = "slant" -- "slant" | "thin" | "padded_slant"
                }
            }

            -- Keymaps
            vim.keymap.set("n", "<Tab>", "<Cmd>BufferLineCycleNext<CR>", {desc = "Next buffer"})
            vim.keymap.set("n", "<S-Tab>", "<Cmd>BufferLineCyclePrev<CR>", {desc = "Prev buffer"})
            vim.keymap.set("n", "<leader>bd", "<Cmd>bdelete<CR>", {desc = "Close buffer"})
        end
    },
    {
        "akinsho/toggleterm.nvim",
        version = "*",
        config = function()
            require("toggleterm").setup {
                size = 70,
                open_mapping = [[<C-\>]], -- fallback mapping
                shade_terminals = true,
                start_in_insert = true,
                persist_size = true,
                direction = "horizontal" -- default
            }


            local Terminal = require("toggleterm.terminal").Terminal

            -- floating terminal
            local float_term = Terminal:new({direction = "float"})
            vim.keymap.set(
                "n",
                "<leader>tf",
                function()
                    float_term:toggle()
                end,
                {desc = "Toggle floating terminal"}
            )

            -- vertical terminal
            local vert_term = Terminal:new({direction = "vertical", size = 160})
            vim.keymap.set(
                "n",
                "<leader>tv",
                function()
                    vert_term:toggle()
                end,
                {desc = "Toggle vertical terminal"}
            )

            -- horizontal terminal
            local hori_term = Terminal:new({direction = "horizontal", size = 60})
            vim.keymap.set(
                "n",
                "<leader>th",
                function()
                    hori_term:toggle()
                end,
                {desc = "Toggle horizontal terminal"}
            )
        end
    },
}

