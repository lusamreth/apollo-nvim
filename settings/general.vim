
" ▞▀▖               ▜ 
" ▌▄▖▞▀▖▛▀▖▞▀▖▙▀▖▝▀▖▐ 
" ▌ ▌▛▀ ▌ ▌▛▀ ▌  ▞▀▌▐ 
" ▝▀ ▝▀▘▘ ▘▝▀▘▘  ▝▀▘ ▘
" General settings

" ▞▀▖▐     ▜    
" ▚▄ ▜▀ ▌ ▌▐ ▞▀▖
" ▖ ▌▐ ▖▚▄▌▐ ▛▀ 
" ▝▀  ▀ ▗▄▘ ▘▝▀▘
" Enable hidden buffers
set hidden
"tab len
set softtabstop=4
set tabstop=4
set shiftwidth=4
set expandtab
"" Directories for swp files
set nobackup
set noswapfile
set autoread
"" Searching
set hlsearch
set incsearch
set ignorecase
set smartcase

" ,<Space> stop the highlight
nnoremap <leader><space> :nohlsearch<CR>

" support utf-8 for devicons
" Devicons only works with nerd-fonts
" So set it in Xresources
set shortmess+=c
" set mode for quality of life
set nowrap "see text as one line
set autoindent " automatically set indent
set smartindent "smart boi!
set number "number all line
set mouse=a "enable mouse
set splitbelow " split win go below (horizontal)
set splitright " split vertically always go right
set fileencoding=utf-8 "file encoding
set encoding=UTF-8
set showtabline=2 "tab len
set cmdheight=2 "more things to see
set pumheight=10 "small popup
set conceallevel=0
" plugin indent
syntax enable
filetype plugin indent on


" ominifunc completion engine
" make it behave like ide
set omnifunc=syntaxcomplete#Complete
"set paste
" show signcolumn as always
set signcolumn=yes
" default g keys

"" no one is really happy until you have this shortcuts lol!
" basically all things are equal
" example :w = :W
cnoreabbrev W! w!
cnoreabbrev Q! q!
cnoreabbrev Qall! qall!
cnoreabbrev Wq wq
cnoreabbrev Wa wa
cnoreabbrev wQ wq
cnoreabbrev WQ
cnoreabbrev W w
cnoreabbrev Q q
cnoreabbrev Qall qall
"Opens a tab edit command with the path of the currently edited file filled
"noremap <Leader>te :tabe <C-R>=expand("%:p:h") . "/" <CR>
"Split
noremap <Leader>h :<C-u>split<CR>
noremap <Leader>v :<C-u>vsplit<CR>

"Vmap for maintain Visual Mode after shifting > and <
vmap < <gv
vmap > >gv

set clipboard+=unnamedplus

aug i3config_ft_detection
  au!
  au BufNewFile,BufRead ~/.config/i3/config set filetype=i3config
aug end

aug conf_detection
  au!
  au BufEnter,BufRead *conf* setf dosini
aug end

" start terminal in insert mode
au BufEnter * if &buftype == 'terminal' | :startinsert | endif

" open terminal on ctrl+;
" uses zsh instead of bash
function! OpenTerminal()
  split term://fish
  resize 10
endfunction

"nnoremap <c-t> :call OpenTerminal()<CR>

set autochdir
set wildmode=longest,list,full
set wildmenu

if has('nvim')
  " use unnamedplus only! or else will double set
  set clipboard=unnamedplus
  if getenv('DISPLAY') == v:null
    exe setenv('DISPLAY', 'FAKE')
  endif
else
  autocmd TextYankPost * call system("c", getreg('"'))
endif


