require("utility.binding")

Imap("<C-@>", "<C-Space>")
Nmap("<C-s>", ":w")
Imap("<C-s>", "w")
local leader = ","

Nmap(leader .. "ff", "Telescope find_files")
Nnoremap("\\", 'lua require("telescope.builtin").live_grep()')
Nnoremap(leader .. "b", 'lua require("telescope.builtin").buffers()')
Nnoremap(leader .. "h", 'lua require("telescope.builtin").help_tags()')
Nnoremap("<C-q>", "qall!")
Nnoremap(leader .. "l", "nohl")

-- vim.cmd("xnoremap K :move '<-2<CR>gv-gv")
-- vim.cmd("xnoremap J :move '>+1<CR>gv-gv")

vim.cmd("tnoremap <Esc> <C-\\><C-n>")

Nnoremap("<Up>", "<Nop>")
Nnoremap("<Down>", "<Nop>")
Nnoremap("<Left>", "<Nop>")
Nnoremap("<Right>", "<Nop>")

Nnoremap("Y", '"+y')
Nnoremap("P", '"+p')
Nnoremap(leader .. "h", "split")
Nnoremap(leader .. "v", "vsplit")

Nnoremap("<M-Up>", ":resize -2")
Nnoremap("<M-Down>", ":resize +2")
Nnoremap("<M-Left>", ":vertical resize -2")
Nnoremap("<M-Right>", ":vertical resize +2")
Nnoremap("<M-q>", "lua import('system.scripts.bufdel').delete_buffer('%')<CR>")

Nnoremap("<C-space>", ":CodeActionMenu")
Nnoremap("<C-S-q>", ":wqa!")

Xnoremap("J", "lua import('system.scripts.move').MoveBlock(1)")
Xnoremap("K", "lua import('system.scripts.move').MoveBlock(-1)")
vim.api.nvim_set_keymap("n", "gk", "<cmd>Telescope projects<cr>", {})
local win_navs = {
    {"<C-h>", "<C-w>h"},
    {"<C-j>", "<C-w>j"},
    {"<C-k>", "<C-w>k"},
    {"<C-l>", "<C-w>l"}
}

for _, win_nav in pairs(win_navs) do
    local key, action = win_nav[1], win_nav[2]
    Nmap(key, action, {binder = true})
    Tnoremap(key, action, {binder = true})
end
