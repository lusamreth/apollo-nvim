"set background="#1e222a"
"let base16colorspace = 16
"colorscheme base16-default-dark
" Color adjustments : if not set will break the

" behavoir of terminal in coloring
" deal with colors
if has('gui_running')
  "debug
  set termguicolors
  echo "gui running"
endif


"let g:everforest_background = 'hard'

colorscheme gruvbox-material
set background=light "or light if you want light mode
if (match($TERM, "-255color") != -1) && (match($TERM, "screen-256color") == -1)
  " screen does not (yet) support truecolor
  set termguicolors
endif

"set termguicolors
"Default settings for alacritty
let g:nvcode_termcolors=256
let $NVIM_TUI_ENABLE_TRUE_COLOR=1
"let g:everforest_better_performance = 1
let g:gruvbox_material_background = 'soft'


syntax on
"colorscheme gruvbox 

" Brighter comments
"call Base16hi("Comment", g:base16_gui09, "", g:base16_cterm09, "", "", "")

set guifont=DroidSansMono_Nerd_Font:h11

"=> Popup menu conf <="
"Pmenu – normal item
"PmenuSel – selected item
"PmenuSbar – scrollbar
"PmenuThumb – thumb of the scrollbar

highlight Pmenu guibg=black guifg=white ctermbg=black ctermfg=white
highlight PmenuSel guibg=green guifg=white ctermbg=green ctermfg=white


"let g:gruvbox_material_palette = {
"    \ 'bg0':              ['#101010',   '234'],
"    \ 'bg1':              ['#262727',   '235'],
"    \ 'bg2':              ['#282828',   '235'],
"    \ 'bg3':              ['#3c3836',   '237'],
"    \ 'bg4':              ['#3c3836',   '237'],
"    \ 'bg5':              ['#504945',   '239'],
"    \ 'bg_statusline1':   ['#282828',   '235'],
"    \ 'bg_statusline2':   ['#32302f',   '235'],
"    \ 'bg_statusline3':   ['#504945',   '239'],
"    \ 'bg_diff_green':    ['#32361a',   '22'],
"    \ 'bg_visual_green':  ['#333e34',   '22'],
"    \ 'bg_diff_red':      ['#3c1f1e',   '52'],
"    \ 'bg_visual_red':    ['#442e2d',   '52'],
"    \ 'bg_diff_blue':     ['#0d3138',   '17'],
"    \ 'bg_visual_blue':   ['#2e3b3b',   '17'],
"    \ 'bg_visual_yellow': ['#473c29',   '94'],
"    \ 'bg_current_word':  ['#32302f',   '236'],
"    \ 'fg0':              ['#d4be98',   '223'],
"    \ 'fg1':              ['#ddc7a1',   '223'],
"    \ 'red':              ['#ea6962',   '167'],
"    \ 'orange':           ['#e78a4e',   '208'],
"    \ 'yellow':           ['#d8a657',   '214'],
"    \ 'green':            ['#a9b665',   '142'],
"    \ 'aqua':             ['#89b482',   '108'],
"    \ 'blue':             ['#7daea3',   '109'],
"    \ 'purple':           ['#d3869b',   '175'],
"    \ 'bg_red':           ['#ea6962',   '167'],
"    \ 'bg_green':         ['#a9b665',   '142'],
"    \ 'bg_yellow':        ['#d8a657',   '214'],
"    \ 'grey0':            ['#7c6f64',   '243'],
"    \ 'grey1':            ['#928374',   '245'],
"    \ 'grey2':            ['#a89984',   '246'],
"    \ 'none':             ['NONE',      'NONE']
"\ }

