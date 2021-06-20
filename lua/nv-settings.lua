TERMINAL = vim.fn.expand('$TERMINAL')
local opt = require("scripts.meta-data")
--print("bdd",opt.bruh)
-- for god sake for why meta-acessory not working
-- Need to manually build custom one! Well that's suck!
-- script -> meta

opt.o.hidden = true -- Required to keep multiple buffers open multiple buffers
opt.o.title = true
opt.o.titlestring="%<%F%=%l/%L - nvim"
--vim.api.nvim_win_set_option(0,"number",true)
opt.o.pumheight = 10 -- Makes popup menu smaller
opt.o.fileencoding = "utf-8" -- The encoding written to file
opt.o.cmdheight = 2 -- More space for displaying messages
opt.o.mouse = "a" -- Enable your mouse
opt.o.splitbelow = true -- Horizontal splits will automatically be below
opt.o.splitright = true -- Vertical splits will automatically be to the right
opt.o.termguicolors = true -- set term gui colors most terminals support this
opt.o.t_Co = "256" -- Support 256 colors
opt.o.conceallevel = 0 -- So that I can see `` in markdown files
opt.o.showtabline = 2 -- Always show tabs
opt.o.showmode = false -- We don't need to see things like -- INSERT -- anymore
opt.o.autoread = true
opt.o.backup = false -- This is recommended by coc
opt.o.writebackup = false -- This is recommended by coc
opt.o.updatetime = 300 -- Faster completion
opt.o.timeoutlen = 0-- By default timeoutlen is 1000 ms
opt.o.clipboard = "unnamedplus" -- Copy paste between vim and everything else
opt.o.smartcase = true
opt.o.guifont = "JetBrainsMono\\ Nerd\\ Font\\ Mono:h18"
opt.o.guifont = "FiraCode\\ Mono\\ Regular\\ Nerd\\ Font\\ Mono"
opt.o.guifont = "Hack\\ Nerd\\ Font\\ Mono"
--vim.o.guifont = "SauceCodePro Nerd Font:h17"
--vim.o.guifont = "FiraCode Nerd Font:h17"
--vim.o.guifont = "JetBrains\\ Mono\\ Regular\\ Nerd\\ Font\\ Complete"
opt.wo.wrap = false -- Display long lines as just one line
opt.wo.number = true -- set numbered lines
opt.wo.relativenumber = false -- set relative number
opt.wo.cursorline = true -- Enable highlighting of the current line
opt.wo.signcolumn = "yes" -- Always show the signcolumn, otherwise it would shift the text each time
opt.g.nvim_tree_disable_netrw = true
opt.bo.smartindent = true -- Makes indenting smart

abbvr_list = {
    "W!   ",
    "Q!   ",
    "Qall!",
    "Wq   ",
    "Wa   ",
    "wQ   ",
    "WQ   ",
    "W    ",
    "Q    ",
    "Qall "
}
function abbrv(list)
   for _,val in pairs(list) do
        vim.cmd(string.format("cnoreabbrev %s %s",val,string.lower(val)))
   end
end

abbrv(abbvr_list)
local util = require("utility")

Defaulti3paths = {
    "~/.config/i3/config",
    "~/.config/sway"
}

function makei3au(i32path)
    local res = {}
    for i,path in pairs(i32path) do
        local tb = {"BufNewFile,BufRead",path,"set filetype=i3config"}
        table.insert(res,tb)
    end
    return res
end

local ConfGroup = {
    {"BufEnter,BufRead","*conf*","setf dosini"},
    {"BufWritePost","lua print('newsave')"}
}

-- table merge is already tested and work as expect !
local tm = util.table_merge(0,ConfGroup,makei3au(Defaulti3paths))
-- test:local bb = util.table_merge(0,{"ok","bonm"},{"duh","bana"},{"shd"},{{"h","s"},{"vvvl","ddd",{"sus"}}})

Create_augroup(tm,"Confdetection")

-- cmd
vim.cmd("filetype plugin indent on")
vim.cmd("au BufEnter * if &buftype == 'terminal' | :startinsert | endif")
vim.cmd('set whichwrap+=<,>,[,],h,l') -- move to next line with theses keys
vim.cmd('syntax on') -- syntax highlighting
vim.cmd('set colorcolumn=99999') -- fix indentline for now
vim.cmd('set iskeyword+=-') -- treat dash separated words as a word text object"
vim.cmd('set shortmess+=c') -- Don't pass messages to |ins-completion-menu|.
vim.cmd('set inccommand=split') -- Make substitution work in realtime
vim.cmd("set autochdir")
vim.cmd("set wildmode=longest,list,full")
vim.cmd("set wildmenu")
vim.cmd('let &titleold="'..TERMINAL..'"')
vim.cmd('set ts=4') -- Insert 2 spaces for a tab
vim.cmd('set sw=4') -- Change the number of space characters inserted for indentation
vim.cmd('set expandtab') -- Converts tabs to spaces
vim.cmd("set noswapfile")
-- set augroup configuration
