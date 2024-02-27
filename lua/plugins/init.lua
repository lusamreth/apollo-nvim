-- This file can be loaded by calling `lua require('plugins')` from your init.vim

local packages = {
    'wbthomason/packer.nvim',
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
    'navarasu/onedark.nvim',
    'lusamreth/PawanChatGPT.nvim',
    'jose-elias-alvarez/null-ls.nvim',
    -- project wide search and replace
    'nvim-pack/nvim-',
    'ckipp01/nvim-jenkinsfile-linter',
    'mfussenegger/nvim-jdtls',
    -- 'lusamreth/PawanChatGPT.nvim',
    'alexghergh/nvim-tmux-navigation',
    -- essentials for neovim config
    'neovim/nvim-lspconfig',
    'mattn/emmet-vim',
    'mlaursen/vim-react-snippets',
    -- formatting tool
    'stevearc/conform.nvim',
    -- neovim code outline
    'stevearc/aerial.nvim',
    'p00f/clangd_extensions.nvim',
    'notomo/gesture.nvim',
    'jay-babu/mason-null-ls.nvim',
    'nvimdev/lspsaga.nvim',
    -- Navigation tool
    'folke/flash.nvim',
    -- git tool
    'kdheepak/lazygit.nvim',
    -- AI code tool
    'Exafunction/codeium.nvim',
    -- {
    --     'jcdickinson/codeium.nvim',
    --     -- commit = '963c460',
    --     -- commit = 'b1ff0d6',
    --     commit = '947acdc',
    -- },
    -- 'Exafunction/codeium.vim',
    -- {
    --     'glepnir/lspsaga.nvim',
    --     opt = true,
    --     branch = 'main',
    --     -- event = 'LspAttach',
    --     config = function()
    --         print('LOADED LSP')
    --         require('lspsaga').setup({})
    --     end,
    --     requires = {
    --         { 'nvim-tree/nvim-web-devicons' },
    --         --Please make sure you install markdown and markdown_inline parser
    --         { 'nvim-treesitter/nvim-treesitter' },
    --     },
    -- },
    {
        'nvim-treesitter/nvim-treesitter',
    },
    'elzr/vim-json',
    'rafamadriz/friendly-snippets',
    -- lua development stuff
    'folke/neodev.nvim',
    'folke/lua-dev.nvim',
    --Icons
    'kyazdani42/nvim-web-devicons',
    -- primary drawer
    'kyazdani42/nvim-tree.lua',
    --primary theme
    'sainnhe/gruvbox-material',
    -- autocomplete
    'norcalli/nvim-colorizer.lua',
    'onsails/lspkind-nvim',
    'lusamreth/gl-providers.nvim',
    -- search dependency
    'kevinhwang91/nvim-hlslens',
    'simrat39/symbols-outline.nvim',
    {
        'folke/which-key.nvim',
        -- commit = 'f03a259',
    },
    -- f03a259
    'terrortylor/nvim-comment',
    'ray-x/lsp_signature.nvim',
    'nvimdev/dashboard-nvim',
    'windwp/nvim-ts-autotag',
    -- 'akinsho/nvim-toggleterm.lua',
    'akinsho/toggleterm.nvim',
    'folke/trouble.nvim',
    'cohama/lexima.vim',
    'p00f/nvim-ts-rainbow',
    -- 'williamboman/nvim-lsp-installer',
    'nvim-telescope/telescope.nvim',
    'nvim-lua/popup.nvim',
    'nvim-lua/plenary.nvim',
    {
        'Saecki/crates.nvim',
        event = { 'BufRead Cargo.toml' },
        requires = { { 'nvim-lua/plenary.nvim' } },
        config = function()
            require('crates').setup()
            print('setting up crates')
            require('cmp').setup.buffer({ sources = { { name = 'crates' } } })
        end,
    },
    'akinsho/bufferline.nvim',
    {
        'lukas-reineke/indent-blankline.nvim',
        { branch = 'main' },
    },
    'vuki656/package-info.nvim',
    'hrsh7th/nvim-cmp',
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-buffer',
    'saadparwaiz1/cmp_luasnip',
    'L3MON4D3/LuaSnip',
    'onsails/vimway-lsp-diag.nvim',
    'kosayoda/nvim-lightbulb',
    'simrat39/rust-tools.nvim',
    'mhartington/formatter.nvim',
    -- 'andweeb/presence.nvim',
    'ahmedkhalf/project.nvim',
    'hoob3rt/lualine.nvim',
    'lewis6991/gitsigns.nvim',
    -- 'famiu/feline.nvim',
    'feline-nvim/feline.nvim',
    'nvim-telescope/telescope-frecency.nvim',
    'tami5/sqlite.lua',
    'weilbith/nvim-code-action-menu',
    'folke/lsp-colors.nvim',
    'sunjon/extmark-toy.nvim',
    {
        'catppuccin/nvim',
        { as = 'catppuccin' },
    },
    'kevinhwang91/rnvimr',
    'xiyaowong/nvim-transparent',
    'mizlan/iswap.nvim',

    {
        'beauwilliams/focus.nvim',
    },

    'MunifTanjim/nui.nvim',

    -- repl integration method
    'hkupty/iron.nvim',
    'nvim-orgmode/orgmode',
    'akinsho/org-bullets.nvim',
    -- 'petobens/poet-v',
    'HallerPatrick/py_lsp.nvim',
    -- 'junnplus/nvim-lsp-setup',

    'junnplus/lsp-setup.nvim',
    {
        'ThePrimeagen/harpoon',
        branch = 'harpoon2',
    },
    'rafcamlet/nvim-luapad',
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

local f = require('plugins.loader')
local loader = f:init_loader()
if loader == nil then
    print('Cannot load plugins!!!\nThe loader is missing.')
else
    loader:load_packages(packages)
end

local function autocompile()
    print('Recompile packages!')
    vim.cmd([[autocmd BufWritePost plugins.lua source <afile> | PackerCompile]])
end

print('Total packages' .. #packages)

-- return require('packer').startup(function()
--     for _, pack in pairs(packages) do
--         use(pack)
--     end
-- end)
