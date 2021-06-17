require("utility.keybinds")


Imap("<C-@>","<C-Space>")
Nmap("<C-s>",":w")
Imap("<C-s>","w")
local leader = ","
Nmap(leader.."ff","Telescope find_files")
Nnoremap("\\",'lua require("telescope.builtin").live_grep()')
Nnoremap(leader.."b",'lua require("telescope.builtin").buffers()')
Nnoremap(leader.."h",'lua require("telescope.builtin").help_tags()')
Nnoremap ("<C-q>","qall")
Nnoremap(leader.."l","nohl")

vim.cmd("xnoremap K :move '<-2<CR>gv-gv")
vim.cmd("xnoremap J :move '>+1<CR>gv-gv")
Nnoremap("Y",'"+y')
Nnoremap("P",'"+p')
Nnoremap(leader.."h","split")
Nnoremap(leader.."v","vsplit")
-- noremap <Leader>Y "+y
-- noremap <Leader>P "+p

