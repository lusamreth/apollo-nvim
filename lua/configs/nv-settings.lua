TERMINAL = vim.fn.expand('$TERMINAL')
local opt = require('system.scripts.meta-data')
--print("bdd",opt.bruh)
-- for god sake for why meta-acessory not working
-- Need to manually build custom one! Well that's suck!
-- script -> meta
opt.o.hidden = true -- Required to keep multiple buffers open multiple buffers
opt.o.title = true
opt.o.titlestring = '%<%F%=%l/%L - nvim'
--vim.api.nvim_win_set_option(0,"number",true)options
opt.o.pumheight = 10 -- Makes popup menu smaller
opt.o.fileencoding = 'utf-8' -- The encoding written to file
opt.o.cmdheight = 2 -- More space for displaying messages
opt.o.mouse = 'a' -- Enable your mouse
opt.o.splitbelow = true -- Horizontal splits will automatically be below
opt.o.splitright = true -- Vertical splits will automatically be to the right
opt.o.termguicolors = true -- set term gui colors most terminals support this
-- opt.o.t_Co = '256' -- Support 256 colors
opt.o.conceallevel = 0 -- So that I can see `` in markdown files
opt.o.showtabline = 2 -- Always show tabs
opt.o.showmode = true -- We don't need to see things like -- INSERT -- anymore
opt.o.autoread = true
opt.o.backup = false -- This is recommended by coc
opt.o.writebackup = false -- This is recommended by coc
opt.o.updatetime = 300 -- Faster completion
opt.o.timeoutlen = 200 -- By default timeoutlen is 1000 ms
opt.o.clipboard = 'unnamedplus' -- Copy paste between vim and everything else
opt.o.smartcase = true
--opt.o.guifont = "JetBrainsMono\\ Nerd\\ Font\\ Mono:h18"
--opt.o.guifont = "FiraCode Retina Nerd Font Complete Mono"
--opt.o.guifont = "JetBrainsMono Nerd Font"
opt.o.guifont = 'Hack Nerd Font Mono:h24'
--vim.o.guifont = "SauceCodePro Nerd Font:h17"
--vim.o.guifont = "FiraCode Nerd Font:h17"
--vim.o.guifont = "JetBrains\\ Mono\\ Regular\\ Nerd\\ Font\\ Complete"
opt.wo.wrap = false -- Display long lines as just one line
opt.wo.number = true -- set numbered lines
opt.wo.relativenumber = true -- set relative number
opt.wo.cursorline = true -- Enable highlighting of the current line
opt.wo.signcolumn = 'yes' -- Always show the signcolumn, otherwise it would shift the text each time
opt.g.nvim_tree_disable_netrw = true

opt.bo.smartindent = true -- Makes indenting smart

-- opt.g.neovide_cursor_antialiasing = true
-- opt.g.neovide_transparency = 1
Abbvr_list = {
    'W!   ',
    'Q!   ',
    'Qall!',
    'Wq   ',
    'Wa   ',
    'wQ   ',
    'WQ   ',
    'W    ',
    'Q    ',
    'Qall ',
}

opt.g.user_emmet_settings = {
    javascript = {
        extends = 'jsx',
    },
}

opt.g.user_emmet_install_global = 1
opt.g.user_emmet_leader_key = '<C-a>'

function Pep8Spec()
    local specs = {
        'tabstop=4',
        'softtabstop=4',
        'shiftwidth=4',
        'textwidth=79',
        'expandtab',
        'autoindent',
        'fileformat=unix',
    }
    for _, spec in pairs(specs) do
        vim.cmd(string.format('set %s', spec))
    end
end

local function abbrv(list)
    for _, val in pairs(list) do
        vim.cmd(string.format('cnoreabbrev %s %s', val, string.lower(val)))
    end
end

abbrv(Abbvr_list)
import('/utility.init', LUAROOT)

Defaulti3paths = {
    '~/.config/i3/config',
    '~/.config/sway',
}

local function makei3au(i32path)
    local res = {}
    for _, path in pairs(i32path) do
        local tb = { 'BufNewFile,BufRead', path, 'set filetype=i3config' }
        table.insert(res, tb)
    end
    return res
end

local ConfGroup = {
    { 'BufEnter,BufRead', '*conf*', 'setf dosini' },
    { 'BufEnter,BufNewFile', '*.json', 'setf json' },
    { 'BufEnter,BufNewFile', '*.py', 'lua Pep8Spec()' },
    { 'BufEnter,BufNewFile', '*.yml', 'setf yaml' },
    { 'BufEnter,BufNewFile', '*.yml', 'setlocal ts=2 sts=2 sw=2 expandtab' },
    {
        'BufEnter,BufNewFile',
        '*.xml',
        'com! FormatXML :%!python3 -c "import xml.dom.minidom, sys; print(xml.dom.minidom.parse(sys.stdin).toprettyxml())"',
    },
}

-- au FileType xml setlocal equalprg=xmllint\ --format\ --recover\ -\ 2>/dev/null

local i3detect = Utils.table_merge(0, ConfGroup, makei3au(Defaulti3paths))
-- test pass!
-- test:
-- local bb = Utils.table_merge(0, {"ok", "bonm"}, {"duh", "bana"}, {"hd"}, {{"h", "s"}, {"vvvl", "ddd", {"sus"}}})
-- print("TBL", vim.inspect(bb))
Create_augroup(i3detect, 'Confdetection')

--=> Popup menu conf <="
--Pmenu – normal item
--PmenuSel – selected item
--PmenuSbar – scrollbar
--PmenuThumb – thumb of the scrollbar

vim.cmd('highlight Pmenu guibg=black guifg=white ctermbg=black ctermfg=white')
vim.cmd('highlight PmenuSel guibg=green guifg=white ctermbg=green ctermfg=white')

-- cmd
vim.cmd('filetype plugin indent on')
vim.cmd("au BufEnter * if &buftype == 'terminal' | :startinsert | endif")
vim.cmd('set whichwrap+=<,>,[,],h,l') -- move to next line with theses keys
vim.cmd('syntax on') -- syntax highlighting
vim.cmd('set colorcolumn=99999') -- fix indentline for now
vim.cmd('set iskeyword+=-') -- treat dash separated words as a word text object"
vim.cmd('set shortmess+=c') -- Don't pass messages to |ins-completion-menu|.
vim.cmd('set inccommand=split') -- Make substitution work in realtime
vim.cmd('set autochdir')
vim.cmd('set wildmode=longest,list,full')
vim.cmd('set wildmenu')
vim.cmd('let &titleold="' .. TERMINAL .. '"')
vim.cmd('set ts=4') -- Insert 2 spaces for a tab
vim.cmd('set sw=4') -- Change the number of space characters inserted for indentation
vim.cmd('set expandtab') -- Converts tabs to spaces
vim.cmd('set noswapfile')
vim.cmd('autocmd BufNewFile,BufRead *.ini setfiletype dosini')
vim.cmd('autocmd BufNewFile,BufRead *.conf setfiletype dosini')
vim.cmd('autocmd BufNewFile,BufRead set number')

vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWinEnter' }, {
    pattern = { '*' },
    command = 'set number',
})

vim.cmd('highlight! HarpoonInactive guibg=NONE guifg=#63698c')
vim.cmd('highlight! HarpoonActive guibg=NONE guifg=white')
vim.cmd('highlight! HarpoonNumberActive guibg=NONE guifg=#7aa2f7')
vim.cmd('highlight! HarpoonNumberInactive guibg=NONE guifg=#7aa2f7')
vim.cmd('highlight! TabLineFill guibg=NONE guifg=white')
--
-- set augroup configuration

-- THEME CONFIGURATION
-- local catppuccino = require('catppuccin')
require('catppuccin').setup({
    flavour = 'mocha', -- mocha, macchiato, frappe, latte
})

vim.api.nvim_command('colorscheme catppuccin')
