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
    --{"glepnir/galaxyline.nvim", {branch = "main"}},
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "0.5-compat"
    },
    "elzr/vim-json",
    "lewis6991/impatient.nvim",
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
    "lusamreth/gl-providers.nvim",
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
    {
        "kabouzeid/nvim-lspinstall",
        disable = false
    },
    "nvim-telescope/telescope.nvim",
    "nvim-lua/popup.nvim",
    "nvim-lua/plenary.nvim",
    {
        "Saecki/crates.nvim",
        event = {"BufRead Cargo.toml"},
        requires = {{"nvim-lua/plenary.nvim"}},
        config = function()
            require("crates").setup()
            print("setting up crates")
            require("cmp").setup.buffer {sources = {{name = "crates"}}}
        end
    },
    "williamboman/nvim-lsp-installer",
    -- buffer manager plugin
    "akinsho/nvim-bufferline.lua",
    {
        "lukas-reineke/indent-blankline.nvim",
        {branch = "main"}
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
    "andweeb/presence.nvim",
    "ahmedkhalf/project.nvim",
    "hoob3rt/lualine.nvim",
    "lewis6991/gitsigns.nvim",
    "famiu/feline.nvim",
    "nvim-telescope/telescope-frecency.nvim",
    "tami5/sqlite.lua",
    "weilbith/nvim-code-action-menu",
    "folke/lsp-colors.nvim",
    "Pocco81/Catppuccino.nvim",
    "sunjon/extmark-toy.nvim",
    "kevinhwang91/rnvimr",
    "tami5/lspsaga.nvim",
    "xiyaowong/nvim-transparent",
    "mizlan/iswap.nvim",
    "MunifTanjim/nui.nvim"
    -- for swapping arg
    -- coq not so accurate and lack of keybinding primarily the
    -- super_tab function
    -- {
    --     "ms-jpq/coq_nvim",
    --     {branch = "coq"}
    -- },
    -- {
    --     "ms-jpq/coq.artifacts",
    --     {branch = "artifacts"}
    -- },
    -- {
    --     "ms-jpq/coq.thirdparty",
    --     {branch = "3p"}
    -- }
    -- "ms-jpq/lua-async-await"
    -- "windwp/windline.nvim"
}

local f = require("plugins.loader")
local loader = f:init_loader()
loader:load_packages(packages)

local function autocompile()
    print("Recompile packages!")
    vim.cmd([[autocmd BufWritePost plugins.lua source <afile> | PackerCompile]])
end

autocompile()
print("Total packages" .. #packages)
