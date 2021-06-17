" This is config for quickscope
let g:qs_highlight_on_keys = ['f', 'F', 't', 'T']

augroup qs_cols
    autocmd ColorScheme * highlight QuickScopePrimary guifg='#00C7DF' gui=underline ctermfg=155 cterm=underline
    autocmd ColorScheme * highlight QuickScopeSecondary guifg='#eF5F70' gui=underline ctermfg=81 cterm=underline
augroup End

let g:qs_max_chars=150

"Commands for quickscope
"f{chars}:go to that character
"F{chars}
"t{chars}:go behind that character
"T{chars}


let g:rnvimr_ex_enable = 1

let g:rnvimr_layout = {
            \ 'relative': 'editor',
            \ 'width': float2nr(round(0.7 * &columns)),
            \ 'height': float2nr(round(0.7 * &lines)),
            \ 'col': float2nr(round(0.15 * &columns)),
            \ 'row': float2nr(round(0.15 * &lines)),
            \ 'style': 'minimal'
            \ }

nmap <M-f> :RnvimrToggle <CR>
tnoremap <M-f> <C-\><C-n>:RnvimrToggle<CR>

let g:rnvimr_action = {
            \ 't': 'NvimEdit tabedit',
            \ '<C-x>': 'NvimEdit split',
            \ '<C-v>': 'NvimEdit vsplit',
            \ 'gw': 'JumpNvimCwd',
            \ 'yw': 'EmitRangerCwd'
            \ }
