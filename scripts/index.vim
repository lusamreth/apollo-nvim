let b:closetag_html_style = 1
" The Silver Searcher
"if executable('ag')
"  " Use ag over grep
"  set grepprg=ag\ --nogroup\ --nocolor
"
"  " Use ag in CtrlP for listing files. Lightning fast and respects .gitignore
"  let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
"
"  " ag is fast enough that CtrlP doesn't need to cache
"  let g:ctrlp_use_caching = 0
"endif
"
"nnoremap K :grep! "\b<C-R><C-W>\b"<CR>:cw<CR>

autocmd Filetype html,xml,xsl,php source $HOME/.config/nvim/scripts/closetag.vim
source $HOME/.config/nvim/scripts/rust-test.vim

