require('utility')
DIR = 'horizontal'
-- vim.opt.signcolumn = 'yes'
local already_open = 0
local panel_color = { '#4c3836', '#fbf1c7' }
local function term_highlighting()
    vim.cmd(string.format('highlight DarkenedPanel guibg=%s guifg=%s', panel_color[1], panel_color[2]))
    vim.cmd('highlight DarkenedStatusline gui=NONE guibg=' .. panel_color[1])
    vim.cmd('highlight DarkenedStatuslineNC cterm=italic gui=NONE guibg=' .. panel_color[1])
    already_open = already_open + 1
end

vim.cmd(string.format('highlight DarkenedPanel guibg=%s,guifg=%s', panel_color[1], panel_color[2]))
-- require('toggleterm').setup({})

require('toggleterm').setup({
    -- size can be a number or function which is passed the current terminal
    size = function(term)
        if already_open == 0 then
            term_highlighting()
        end
        if term.direction == 'horizontal' then
            return 12
        elseif term.direction == 'vertical' then
            return vim.o.columns * 0.38
        end
    end,
    open_mapping = [[<c-\>]],
    hide_numbers = true, -- hide the number column in toggleterm buffers
    shade_filetypes = { 'none', 'fzf' },
    shade_terminals = true,
    start_in_insert = true,
    persist_size = false, -- keep size persistent even window change size
    --direction = 'vertical' | 'horizontal' | 'window' | 'float',
    close_on_exit = false, -- close the terminal window when the process exits
    -- direction = "vertical",
    direction = DIR,
    shell = vim.o.shell, -- change the default shell
    -- This field is only relevant if direction is set to 'float'
    float_opts = {
        -- The border key is *almost* the same as 'nvim_win_open'
        -- see :h nvim_win_open for details on borders however
        -- the 'curved' border is a custom border type
        -- not natively supported but implemented in this plugin.
        --border = 'single' | 'double' | 'shadow' | 'curved' | ... other options supported by win open
        border = 'curved',
        width = 60,
        height = 20,
        winblend = 3,
        -- use to change background color
        --highlight DarkenedPanel guibg,guifg
        highlights = {
            border = 'Normal',
            background = 'Normal',
        },
    },
})

--custom terminal

local Terminal = require('toggleterm.terminal').Terminal
local ShellRegistry = {
    initial = 0,
}

local function buildShTerm(filename)
    local current_dir = vim.cmd('pwd')
    local command = 'shellcheck ' .. filename
    local shellcheck = Terminal:new({
        cmd = command,
        --cmd = "ls",
        direction = DIR,
        dir = current_dir,
        hidden = false,
        on_open = function(term)
            vim.api.nvim_buf_set_keymap(term.bufnr, 'n', 'q', '<cmd>close<CR>', { noremap = true, silent = true })
            -- vim.api.nvim_buf_set_keymap(term.bufnr, 'n', 'q', '<cmd>close<CR>', { noremap = true, silent = true })
        end,
        on_close = function(term)
            -- vim.cmd('startinsert!')
        end,
    })
    return shellcheck
end

function SHCHECK()
    local filename = vim.fn.expand('%:t')
    local shellcheck = buildShTerm(filename)

    shellcheck:close()
    if shellcheck ~= nil then
        shellcheck:open()
    end
end

-- local Terminal = require('toggleterm.terminal').Terminal

local current_dir = vim.cmd('pwd')
local lazygit = Terminal:new({
    cmd = 'lazygit',
    direction = 'float',
    dir = current_dir,
    float_opts = {
        border = 'double',
    },
    -- function to run on opening the terminal
    on_open = function(term)
        vim.api.nvim_buf_set_keymap(term.bufnr, 'n', 'q', '<cmd>close<CR>', { noremap = true, silent = true })
        vim.api.nvim_buf_set_keymap(term.bufnr, 't', 'jk', [[<C-\><C-n><C-w>q]], { noremap = true, silent = true })
    end,
    -- function to run on closing the terminal
    on_close = function(term)
        -- vim.cmd('startinsert!')
        -- vim.cmd('startinsert!')
    end,
})

-- vim.keymap.set('t', '<esc>', [[<C-\><C-n><C-w>q]], { noremap = true, silent = true })

function _lazygit_toggle()
    lazygit:toggle()
end

local save_hook = {
    { 'BufEnter,BufRead', '*sh*', "lua print('init bash savehook')" },
    -- { 'BufWritePost', '*sh*', 'lua SHCHECK()' },
}
vim.api.nvim_set_keymap('n', 'lg', '<cmd>lua _lazygit_toggle()<CR>', { noremap = true, silent = true })
-- vim.keymap.set('t', 'jk', '<cmd>lua _lazygit_toggle()<CR>', { noremap = true, silent = true })
Create_augroup(save_hook, 'bashtermhook')
--Nnoremap("<C-t>","lua vim.cmd('ToggleTerm')",{})
