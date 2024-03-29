require('utility.binding')

Imap('<C-@>', '<C-Space>')
Nmap('<C-s>', ':w')
Imap('<C-s>', 'w')
local leader = ','

Nmap(leader .. 'ff', 'Telescope find_files')
Nnoremap('\\', 'lua require("telescope.builtin").live_grep()')
Nnoremap(leader .. 'fb', 'lua require("telescope.builtin").buffers()')
Nnoremap(leader .. 'fh', 'lua require("telescope.builtin").help_tags()')
Nnoremap(leader .. 'fr', ':RnvimrToggle')
Nnoremap('<C-q>', 'qall!')
Nnoremap(leader .. 'l', 'nohl')

-- vim.cmd("xnoremap K :move '<-2<CR>gv-gv")
-- vim.cmd("xnoremap J :move '>+1<CR>gv-gv")

vim.cmd('tnoremap <Esc> <C-\\><C-n>')

Nnoremap('<Up>', '<Nop>')
Nnoremap('<Down>', '<Nop>')
Nnoremap('<Left>', '<Nop>')
Nnoremap('<Right>', '<Nop>')

Nnoremap('Y', '"+y')
Nnoremap('P', '"+p')
Nnoremap(leader .. 'h', 'split')
Nnoremap(leader .. 'v', 'vsplit')

Nnoremap('<M-Up>', ':resize -2')
Nnoremap('<M-Down>', ':resize +2')
Nnoremap('<M-Left>', ':vertical resize -2')
Nnoremap('<M-Right>', ':vertical resize +2')
Nnoremap('<M-q>', "lua import('system.scripts.bufdel').delete_buffer('%')<CR>")

-- Nnoremap('<C-space>', ':CodeActionMenu')
Nnoremap('<C-S-q>', ':wqa!')
Xnoremap('J', "lua import('system.scripts.move').MoveBlock(1)")
Xnoremap('K', "lua import('system.scripts.move').MoveBlock(-1)")

Nnoremap('<space>fs', ':ISwapWith')

-- vim.api.nvim_set_keymap('n', 'gk', '<cmd>Telescope projects<cr>', {})
vim.keymap.set('n', '<C-o>', function()
    require('flash').jump()
end)

function _G.set_terminal_keymaps()
    local opts = { noremap = true }
    vim.api.nvim_buf_set_keymap(0, 't', '<esc>', [[<C-\><C-n>]], opts)
    vim.api.nvim_buf_set_keymap(0, 't', 'jk', [[<C-\><C-n>]], opts)
    vim.api.nvim_buf_set_keymap(0, 't', '<C-h>', [[<C-\><C-n><C-W>h]], opts)
    vim.api.nvim_buf_set_keymap(0, 't', '<C-j>', [[<C-\><C-n><C-W>j]], opts)
    vim.api.nvim_buf_set_keymap(0, 't', '<C-k>', [[<C-\><C-n><C-W>k]], opts)
    vim.api.nvim_buf_set_keymap(0, 't', '<C-l>', [[<C-\><C-n><C-W>l]], opts)
end

vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')

local win_navs = {
    { '<C-h>', '<C-w>h' },
    { '<C-j>', '<C-w>j' },
    { '<C-k>', '<C-w>k' },
    { '<C-l>', '<C-w>l' },
}

for _, win_nav in pairs(win_navs) do
    local key, action = win_nav[1], win_nav[2]
    Nmap(key, action, { binder = true })
    Nnoremap(key, action, { binder = true })
end

local harpoon = require('harpoon')

-- REQUIRED
harpoon:setup({

    settings = {
        save_on_toggle = false,
        sync_on_ui_close = false,
        key = function()
            return vim.loop.cwd()
        end,
    },
})
-- REQUIRED

Nnoremap('hf', function()
    print('openning harpoon registry')
    return harpoon.ui:toggle_quick_menu(harpoon:list())
end)

Nnoremap('hs', function()
    print('adding file to harpoon registry')
    return harpoon:list():append()
end)

Nnoremap('hm', function()
    print('harpoon next')
    return harpoon.ui.nav_next()
end)

Nnoremap('hn', function()
    print('harpoon prev')
    return harpoon.ui.nav_prev()
end)

vim.api.nvim_set_keymap('n', '<M-r>', '<cmd>lua Reload()<CR>', { noremap = true, silent = true })
