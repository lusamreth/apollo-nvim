-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
-- vim.cmd [[packadd packer.nvim]]
-- return require('packer').startup(function()
--         -- configs goes here
--     end
-- )
--

local packages = {
    "wbthomason/packer.nvim",
    "neovim/nvim-lspconfig",
    {"glepnir/galaxyline.nvim", {branch = "main"}},
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "0.5-compat"
    },
    "elzr/vim-json",
    "tjdevries/nlua.nvim",
    --Icons
    "kyazdani42/nvim-web-devicons",
    -- primary drawer
    "kyazdani42/nvim-tree.lua",
    --primary theme
    "sainnhe/gruvbox-material",
    -- autocomplete
    "hrsh7th/nvim-compe",
    "norcalli/nvim-colorizer.lua",
    "onsails/lspkind-nvim",
    -- search dependency
    "kevinhwang91/nvim-hlslens",
    "simrat39/symbols-outline.nvim",
    "folke/which-key.nvim",
    "terrortylor/nvim-comment",
    "ray-x/lsp_signature.nvim",
    "glepnir/dashboard-nvim",
    "windwp/nvim-ts-autotag",
    "akinsho/nvim-toggleterm.lua",
    "folke/trouble.nvim",
    "cohama/lexima.vim",
    "p00f/nvim-ts-rainbow",
    "kabouzeid/nvim-lspinstall",
    "nvim-telescope/telescope.nvim",
    "nvim-lua/popup.nvim",
    "nvim-lua/plenary.nvim",
    "mhinz/vim-crates",
    -- buffer manager plugin
    "akinsho/nvim-bufferline.lua",
    {
        "lukas-reineke/indent-blankline.nvim",
        {branch = "master"}
    },
    "vuki656/package-info.nvim",
    "hrsh7th/nvim-cmp",
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "saadparwaiz1/cmp_luasnip",
    "L3MON4D3/LuaSnip",
    "onsails/vimway-lsp-diag.nvim",
    "kosayoda/nvim-lightbulb",
    "simrat39/rust-tools.nvim",
    "mhartington/formatter.nvim",
    "andweeb/presence.nvim"
}

local f = require("plugins.loader")
local loader = f:init_loader()
loader:load_packages(packages)

print("this loader", loader)
print("size" .. #packages)
