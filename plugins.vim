" ▛▀▖▜       ▗       
" ▙▄▘▐ ▌ ▌▞▀▌▄ ▛▀▖▞▀▘
" ▌  ▐ ▌ ▌▚▄▌▐ ▌ ▌▝▀▖
" ▘   ▘▝▀▘▗▄▘▀▘▘ ▘▀▀ 
"auto-install vim-plug
if empty(glob('~/.config/nvim/autoload/plug.vim'))
  silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  "autocmd VimEnter * PlugInstall
  autocmd VimEnter * PlugInstall | source $MYVIMRC
endif 
    
call plug#begin('~/.nvim/autoload/plugged')
"Plug 'alvan/vim-closetag'
"Plug 'scrooloose/nerdtree'
Plug 'autozimu/LanguageClient-neovim', {
    \ 'branch': 'next',
    \ 'do': 'bash install.sh',
\}

"install Dis when you learn lua!
"Plug 'glepnir/galaxyline.nvim' , {'branch': 'main'}
"Plug 'mboughaba/i3config.vim'
"Plug 'tpope/vim-fugitive'
Plug 'ryanoasis/vim-webdevicons'
"Plug 'neoclide/coc.nvim', { 'branch': 'master', 'do': 'yarn install --frozen-lockfile' }
"Plug 'dense-analysis/ale'
"Plug 'voldikss/vim-floaterm'

"Plug 'rust-lang/rust.vim'
"Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
"Plug 'junegunn/fzf.vim'
"Plug 'airblade/vim-rooter'
"base16 colors theme
"Plug 'chriskempson/base16-vim'
" plugins for writing document
"Plug 'junegunn/limelight.vim'
"Plug 'junegunn/goyo.vim'
Plug 'mhinz/vim-crates'
Plug 'meain/vim-package-info', { 'do': 'npm install' }
"Plug 'ervandew/supertab'
"Plug 'SirVer/ultisnips'
Plug 'mattn/emmet-vim'
Plug 'skywind3000/asyncrun.vim'

"Plug 'maralla/completor.vim'
Plug 'kevinhwang91/rnvimr', {'do': 'make sync'}
Plug 'elzr/vim-json'
Plug 'tjdevries/nlua.nvim'

"Indent system
"Plug 'Yggdroot/indentLine' "blankline indentation Plug 'lukas-reineke/indent-blankline.nvim'
Plug 'lukas-reineke/indent-blankline.nvim',{ 'branch' : 'lua'}
"Nightly Plugins
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'} 
Plug 'glepnir/galaxyline.nvim' , {'branch': 'main'}
"Plug 'nvim-lua/plenary.nvim'
Plug 'kyazdani42/nvim-web-devicons' " lua
Plug 'kyazdani42/nvim-tree.lua'
Plug 'akinsho/nvim-bufferline.lua'

Plug 'svermeulen/vimpeccable'
"Plug 'glepnir/zephyr-nvim'
"Automatically install dependencies !
Plug 'ms-jpq/chadtree', {'branch': 'chad', 'do': 'python3 -m chadtree deps'}
Plug 'sainnhe/gruvbox-material'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'

"Lush for components customization!
"Themes zephyr and everforest
Plug 'glepnir/zephyr-nvim'
"Plug 'sainnhe/everforest'
Plug 'christianchiarulli/nvcode-color-schemes.vim'
Plug 'sainnhe/sonokai'

"Auto completion plugin for nvim. use for tab completion
"require fetching for lang_server
Plug 'hrsh7th/nvim-compe'
"languages server protocol built and maintain by neovim team!
"good for running existing lang-server
Plug 'neovim/nvim-lspconfig'
"Make it easy to install lang-server similar to what coc provides
Plug 'kabouzeid/nvim-lspinstall'

"Auto closing parenthesis
Plug 'cohama/lexima.vim'
Plug 'hrsh7th/vim-vsnip'
Plug 'p00f/nvim-ts-rainbow'
Plug 'norcalli/nvim-colorizer.lua'
"pictogram plugin
Plug 'onsails/lspkind-nvim'
Plug 'simrat39/rust-tools.nvim'
"Plug 'nvim-lua/completion-nvim'
Plug 'nvim-lua/lsp_extensions.nvim'
Plug 'nvim-lua/lsp-status.nvim'
Plug 'kosayoda/nvim-lightbulb'
"Plug 'glepnir/lspsaga.nvim'
"best use for formatting
Plug 'mhartington/formatter.nvim'
Plug 'kevinhwang91/nvim-hlslens'
"Plug 'mg979/vim-visual-multi'
Plug 'simrat39/symbols-outline.nvim'
Plug 'folke/which-key.nvim'
Plug 'terrortylor/nvim-comment'
Plug 'ray-x/lsp_signature.nvim'
Plug 'glepnir/dashboard-nvim'
Plug 'windwp/nvim-ts-autotag'
Plug 'akinsho/nvim-toggleterm.lua'
Plug 'folke/trouble.nvim'
Plug 'chrisbra/vim-xml-runtime'
Plug 'andweeb/presence.nvim'
call plug#end()
