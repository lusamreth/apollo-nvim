--[[
            "=================     ===============     ===============   ========  ========",
            "\\ . . . . . . .\\\\   //. . . . . . .\\\\   //. . . . . . .\\\\  \\\\. . .  //",
            "||. . ._____. . .|| ||. . ._____. . .|| ||. . ._____. . .|| || . . .\\/ . . .||",
           "|| . .||   ||. . || || . .||   ||. . || || . .||   ||. . || ||. . . . . . .  ||",
            "||. . ||   || . .|| ||. . ||   || . .|| ||. . ||   || . .|| || . | . . . . . ||",
            "|| . .||   ||. _-|| ||-_ .||   ||. . || || . .||   ||. _-|| ||-_.|\\ . . . . ||",
            "||. . ||   ||-'  || ||  `-||   || . .|| ||. . ||   ||-'  || ||  `|\\_ . .|. .||",
            "|| . _||   ||    || ||    ||   ||_ . || || . _||   ||    || ||   |\\ `-_/| . ||",
            "||_-' ||  .|/    || ||    \\|.  || `-_|| ||_-' ||  .|/    || ||   | \\  / |-_||",
            "||    ||_-'      || ||      `-_||    || ||    ||_-'      || ||   | \\  / |  `||",
            "||    `'         || ||         `'    || ||    `'         || ||   | \\  / |   ||",
            "||            .===' `===.         .==='.`===.         .===' /==. |  \\/  |   ||",
            "||         .=='   \\_|-_ `===. .==='   _|_   `===. .===' _-|/   `==  \\/  |  ||",
            "||      .=='    _-'    `-_  `='    _-'   `-_    `='  _-'   `-_  /|  \\/  |   ||",
            "||   .=='    _-'          '-__\\._-'         '-_./__-'         `' |. /|  |   ||",
            "||.=='    _-'                                                     `' |  /==. ||",
            "=='    _-'                         N V I M S                          \\/   `==",
            "\\   _-'                                                                `-_   /",
            " `''                                                                      ``'"
]]

require('module-loaders')
require('plugins')
vim.loader.enable()

vim.g.python3_host_prog = '/usr/bin/python3'
vim.g.python_host_prog = '/usr/bin/python2.7'
vim.g.poetv_executables = { 'poetry', 'pipenv' }

table.unpack = table.unpack or unpack
-- this custom loader must be loaded first before the system
-- starts sourcing core files and plugins

vim.keymap.set('n', '<leader>b', '<cmd>%bd|e#<cr>', { desc = 'Close all buffers but the current one' })
-- https://stackoverflow.com/a/42071865/516188
vim.cmd('filetype plugin on')
vim.cmd('filetype on')

require('utility')
require('clangd_extensions').setup()
require('nvim-treesitter.configs').setup({
    highlight = {
        enable = true,
        -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
        -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
        -- Using this option may slow down your editor, and you may see some duplicate highlights.
        -- Instead of true it can also be a list of languages
        additional_vim_regex_highlighting = { 'php' },
    },
    query_linter = {
        enable = true,
        use_virtual_text = true,
        lint_events = { 'BufWrite', 'CursorHold' },
    },
    rainbow = {
        enable = true,
        extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
        max_file_lines = nil, -- Do not enable for files with more than n lines, int
        -- colors = {}, -- table of hex strings
        -- termcolors = {} -- table of colour name strings
    },
    indent = {
        enable = false, -- Really breaks stuff if true
    },
    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = 'gnn',
            node_incremental = 'grn',
            scope_incremental = 'grc',
            node_decremental = 'grm',
        },
    },
})

require('colorizer').setup()
function Reload()
    print('Reloaded!')
    vim.cmd('source %')
end

vim.api.nvim_set_keymap('n', '<M-r>', '<cmd>lua Reload()<CR>', { noremap = true, silent = true })

-- start importing modules(plugin configs)
access_module('nv-hlsearch')
access_module('nv-layout')
-- access_module('nv-chatgpt')
-- access_module('nv-gesture')
access_module('nv-whichkey')
access_module('nv-term')

access_module('nv-bufferline')
access_module('nv-tree.init')
access_module('nv-cmp')
access_module('nv-tmux-navigator')

access_core('lsp.init')
access_core('lsp.languages.init')

-- curl_post('https://api.pawan.krd/v1/chat/completions')
-- make_call('https://api.pawan.krd/v1/chat/completions')

-- vim.cmd('source /home/lusamreth/.config/nvim/emmet.vim')
require('configs.nv-settings')
require('configs.keybinding')

access_system('inspectors.table')
access_system('inspectors.interface-builder')

-- statusline mutate the original import
vim.cmd('luafile ~/.config/nvim/lua/core/statusline/init.lua')

-- because of how statusline utilise import networks, we have to reset the import
-- definition
reset_import()

require('nvim_comment').setup({
    -- Linters prefer comment and line to have a space in between markers
    marker_padding = true,
    -- should comment out empty or whitespace only lines
    comment_empty = false,
    -- Should key mappings be created
    create_mappings = true,
    -- Normal mode mapping left hand side
    line_mapping = 'gcc',
    -- Visual/Operator mapping left hand side
    operator_mapping = 'gc',
})

access_module('nv-orgmode')

local Api = {
    OPENAI_API_KEY = 'pk-INJhHJmyfChkKKFxpustWlkUyYPfJDPoFztopNvzLCgvSbCw',
}
local curl = require('plenary.curl')
local job = require('plenary.job')

function Api.make_call(url, params, cb)
    TMP_MSG_FILENAME = os.tmpname()
    local f = io.open(TMP_MSG_FILENAME, 'w+')
    if f == nil then
        vim.notify('Cannot open temporary message file: ' .. TMP_MSG_FILENAME, vim.log.levels.ERROR)
        return
    end

    -- vim.pretty_print(vim.fn.json_encode(params))

    local jsonified = vim.fn.json_encode({
        model = 'gpt-3.5-turbo',
        max_tokens = 3000,
        messages = params.messages,
    })

    f:write(jsonified)
    f:close()

    -- Api.handle_response(response, 0, cb)
    Api.job = job:new({
        command = 'curl',
        args = {
            url,
            '-H',
            'Content-Type: application/json',
            '-H',
            'Authorization: Bearer ' .. Api.OPENAI_API_KEY,
            '-d',
            '@' .. TMP_MSG_FILENAME,
        },
        on_exit = vim.schedule_wrap(function(response, exit_code)
            print('RESPONSEE', response, exit_code)
            vim.pretty_print(response)
            -- Api.handle_response(response, exit_code, cb)
        end),
    }):start()
end

local gpt_payload = {
    model = 'gpt-3.5-turbo',
    max_tokens = 3000,
    messages = {
        {
            role = 'system',
            content = 'a very helpful assistant',
        },
        {
            role = 'user',
            content = 'hello',
        },
    },
}

-- vim.keymap.set({ 'n' }, 'z', function()
--     Api.make_call('https://api.pawan.krd/v1/chat/completions', gpt_payload)
-- end)
vim.g.user_emmet_leader_key = '<C-z>'

local function init_emmet()
    -- Emmet settings
    vim.g.user_emmet_leader_key = '<C-space>'
    -- vim.g.user_emmet_leader_key = ','
    vim.g.user_emmet_mode = 'i'
    vim.g.user_emmet_settings = {
        javascript = {
            extends = 'jsx',
        },
    }

    -- opt.g.user_emmet_install_global = 1
end

require('focus').setup({ hybridnumber = true, excluded_filetypes = { 'toggleterm' }, treewidth = 20 })

init_emmet()
access_module('nv-iron')
access_module('nv-aerial')
require('codeium').setup({})
-- access_module('nv-pilot.init')

vim.cmd('syntax on')
