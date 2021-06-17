
" ▞▀▖      ▐        
" ▚▄ ▌ ▌▛▀▖▜▀ ▝▀▖▚▗▘
" ▖ ▌▚▄▌▌ ▌▐ ▖▞▀▌▗▚ 
" ▝▀ ▗▄▘▘ ▘ ▀ ▝▀▘▘ ▘
syntax enable
filetype plugin indent on

if has('nvim')
  autocmd BufRead Cargo.toml call crates#toggle()
endif

highlight Crates ctermfg=green ctermbg=NONE cterm=NONE
" or link it to another highlight group
highlight link Crates WarningMsg

" extensions
" coc-rust-analyzer'

" Rust language config file!
" //////////////////////////

"PYTHON AND C setup
function PyInd()
    set tabstop=4
    set expandtab
    set textwidth=79
endf

au BufRead,BufNewFile *py,*pyw,*.c,*.h silent! call PyInd()


"set shiftwidth=4 is already set
function Select_c_style()
    if search('^\t', 'n', 150)
        set noexpandtab
    el 
        set expandtab
    en
endf

"If c file selects c format
au BufRead,BufNewFile *.c,*.h silent! call Select_c_style()
au BufRead,BufNewFile Makefile* silent! set noexpandtab

highlight BadWhitespace ctermbg=red guibg=red


au BufRead,BufNewFile *.py,*.pyw,*.c,*.h silent! hi Green ctermfg=green

let python_highlight_all = 1

" for rasi conf
"au BufNewFile,BufRead /*.rasi setf css

au BufRead,BufNewFile *.json set filetype=json
au BufRead,BufNewFile *.yml set filetype=yaml
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab 

set foldlevelstart=20

let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'
let g:ale_lint_on_text_changed = 'never'
