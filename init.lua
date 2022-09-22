--[[form
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
require('impatient')

vim.g.python3_host_prog = '/usr/bin/python3.10'
vim.g.python_host_prog = '/usr/bin/python2.7'
-- vim.g.poetv_executables = { 'poetry', 'pipenv' }

table.unpack = table.unpack or unpack
-- this custom loader must be loaded first before the system
-- starts sourcing core files and plugins

require('utility')

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
-- access_module('nv-projects')

access_module('nv-whichkey')
access_module('nv-term')
-- require("toggleterm").setup()

access_module('nv-bufferline')
access_module('nv-tree')

access_core('lsp.init')
access_core('lsp.languages.init')
-- vim.cmd('source /home/lusamreth/.config/nvim/emmet.vim')
require('configs.nv-settings')
require('configs.keybinding')

access_system('inspectors.table')
access_system('inspectors.interface-builder')

-- statusline mutate the original import
vim.cmd('luafile ~/nvim-proto-2/lua/core/statusline/init.lua')

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

vim.cmd('syntax on')
