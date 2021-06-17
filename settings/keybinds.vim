
"nmap <silent> [g <Plug>(coc-diagnostic-prev)
"nmap <silent> ]g <Plug>(coc-diagnostic-next)
"" GoTo code navigation.
"nmap <silent> gd <Plug>(coc-definition)
"nmap <silent> gy <Plug>(coc-type-definition)
"nmap <silent> gi <Plug>(coc-implementation)
"nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>
verbose nmap <C-s> :w <CR>
verbose imap <C-s> <Esc>:w<CR>

" set null to space in n-mode
nnoremap <Space> <Nop>

nmap <S-tab> :tabprevious<CR>
nmap <Tab>   :tabnext<CR>
"nmap <C-t>   :tabnew<CR>
" nerd tree toggle key
"NERDTreeToggle
verbose nmap <C-n> :NERDTreeToggle<CR>
" Tab Control (others) Alt + num-tab
 map <M-1> 1gt
 map <M-2> 2gt
 map <M-3> 3gt
 map <M-4> 4gt
 map <M-5> 5gt
 map <M-6> 6gt
 map <M-7> 7gt
 map <M-8> 8gt
 map <M-9> 9gt

" better window navigation
  nnoremap <C-h> <C-w>h
  nnoremap <C-j> <C-w>j
  nnoremap <C-k> <C-w>k
  nnoremap <C-l> <C-w>l

  " Use alt + hjkl to resize windows
  nnoremap <silent> <M-j>    :resize -2<CR>
  nnoremap <silent> <M-k>    :resize +2<CR>
  nnoremap <silent> <M-h>    :vertical resize -2<CR>
  nnoremap <silent> <M-l>    :vertical resize +2<CR>

" <TAB>: completion.
"inoremap <silent> <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
" force to close 
"nnoremap <M-q> :tabclose <CR>
nnoremap <C-S-q> :wqa! <CR>
let NERDTreeShowHidden=1

"Fuzzy finder key
"nnoremap <C-f> :Files <CR>
"nnoremap <C-h> :History <CR> 
" The highlight completion appear during typing  
" and shorten as the word is completing
inoremap <expr> <C-n> pumvisible() ? '<C-n>' :
  \ '<C-n><C-r>=pumvisible() ? "\<lt>Down>" : ""<CR>'

inoremap <expr> <M-,> pumvisible() ? '<C-n>' :
  \ '<C-x><C-o><C-n><C-p><C-r>=pumvisible() ? "\<lt>Down>" : ""<CR>'
" open omni completion menu closing previous if open and opening new menu without changing the text
noremap <expr> <C-Space> (pumvisible() ? (col('.') > 1 ? '<Esc>i<Right>' : '<Esc>i') : '') .
            \ '<C-x><C-o><C-r>=pumvisible() ? "\<lt><C-n>\<lt><C-p>\<lt>Down>" : ""<CR>'
"inoremap <expr> <TAB> pumvisible() \|\| &omnifunc == '' ?
"\ "\<lt>C-n>" :
"\ "\<lt>C-x>\<lt>C-o><c-r>=pumvisible() ?" .
"\ "\"\\<lt>c-n>\\<lt>c-p>\\<lt>c-n>\" :" .
"\ "\" \\<lt>bs>\\<lt>C-n>\"\<CR>"

imap <C-@> <C-Space>

"keybind for silver-searcher
nnoremap \ :Ag <CR>

" Don't Touch those arrow keys again
noremap <Up> <Nop>
noremap <Down> <Nop>
noremap <Left> <Nop>
noremap <Right> <Nop>

" Move selected line / block of text in visual mode
" shift + k to move up
" shift + j to move down
xnoremap K :move '<-2<CR>gv-gv
xnoremap J :move '>+1<CR>gv-gv

" Better nav for omnicomplete
inoremap <expr> <c-j> ("\<C-n>")
inoremap <expr> <c-k> ("\<C-p>")

"Fixing bad pasting in vim
imap <C-v> ^O:set paste<Enter>^R+^O:set nopaste<Enter>

"Enabling clipboard copy and paste
noremap <Leader>Y "+y
noremap <Leader>P "+p

inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
"inoremap <silent><expr> <c-space> coc#refresh()

" use <tab> for trigger completion and navigate to the next complete item
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~ '\s'
endfunction

"inoremap <silent><expr> <Tab>
"      \ pumvisible() ? "\<C-n>" :
"      \ <SID>check_back_space() ? "\<Tab>" :
"      \ coc#refresh()

" Amazing Zoom / Restore window.
function! s:ZoomToggle() abort
    if exists('t:zoomed') && t:zoomed
        execute t:zoom_winrestcmd
        let t:zoomed = 0
    else
        let t:zoom_winrestcmd = winrestcmd()
        resize
        vertical resize
        let t:zoomed = 1
    endif
endfunction

command! ZoomToggle call s:ZoomToggle()
nnoremap <silent> <C-A> :ZoomToggle<CR>

augroup EmmetSettings
     let g:user_emmet_expandabbr_key='<c-space>'
     autocmd! Filetype html,xhtml imap <expr> <c-space> emmet#expandAbbrIntelligent("\<c-space>")    
augroup End

autocmd FileType .py let b:coc_suggest_disable = 1
"nmap <c-x> :CocCommand rust-analyzer.analyzerStatus	
tnoremap <Esc> <C-\><C-n>

let mapleader = ","
"telescope keybindings 
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap \ <cmd>lua require('telescope.builtin').live_grep()<cr>
nnoremap tb <cmd>lua require('telescope.builtin').buffers()<cr>
nnoremap <space-h> <cmd>lua require('telescope.builtin').help_tags()<cr>
nnoremap <C-z> <cmd>CHADopen<CR>
"nnoremap <leader>e <cmd>NvimTreeToggle<CR>

"vim.api.nvim_set_keymap('n', '<Leader>e', ':NvimTreeToggle<CR>', {noremap = true, silent = true})
"ease of use !
nnoremap <C-q> <cmd>qall<cr>

nnoremap <leader>l <cmd>call setqflist([])<cr>
nnoremap <silent><leader>ca <cmd>lua require('lspsaga.codeaction').code_action()<CR>
nnoremap <leader>q <cmd>qall<cr>

"noremap <silent> m <Cmd>execute('normal! ' . v:count1 . 'n')<CR>
"            \<Cmd>lua require('hlslens').start()<CR>
"noremap <silent> n <Cmd>execute('normal! ' . v:count1 . 'N')<CR>
"            \<Cmd>lua require('hlslens').start()<CR>

"noremap * *<Cmd>lua require('hlslens').start()<CR>
"noremap # #<Cmd>lua require('hlslens').start()<CR>
"noremap g* g*<Cmd>lua require('hlslens').start()<CR>
"noremap g# g#<Cmd>lua require('hlslens').start()<CR>

" use : instead of <Cmd>
nnoremap <silent> <leader>l :noh<CR>
"expr is what running on cmd
