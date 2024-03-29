require('which-key').setup({

    internal = { 'a', 'b', 'c', '\6', '<80><fc>\bJ', '<80><fc>\f<80>k2', '‥', '<80><fc><88>‥', '<80><fc>\16>', '<80><fc><80><', '<', '<80><fc>\4-' },
    keys = 'abc\6<80><fc>\bJ<80><fc>\f<80>k2‥<80><fc><88>‥<80><fc>\16><80><fc><80><<<80><fc>\4-',
    notation = { 'a', 'b', 'c', '<C-F>', '<M-J>', '<M-C-F2>', '‥', '<D-A-‥>', '<T->>', '<D-<>', '<lt>', '<C-->' },

    plugins = {
        marks = true, -- shows a list of your marks on ' and `
        registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
        -- the presets plugin, adds help for a bunch of default keybindings in Neovim
        -- No actual key bindings are created
        presets = {
            operators = true, -- adds help for operators like d, y, ...
            motions = true, -- adds help for motions
            text_objects = true, -- help for text objects triggered after entering an operator
            windows = true, -- default bindings on <c-w>
            nav = true, -- misc bindings to work with windows
            z = false, -- bindings for folds, spelling and others prefixed with z
            g = false, -- bindings for prefixed with g
        },
    },
    icons = {
        breadcrumb = '»', -- symbol used in the command line area that shows your active key combo
        separator = '➜', -- symbol used between a key and it's label
        group = '+', -- symbol prepended to a group
    },
    window = {
        border = 'single', -- none, single, double, shadow
        position = 'bottom', -- bottom, top
        margin = { 1, 0, 1, 0 }, -- extra window margin [top, right, bottom, left]
        padding = { 2, 2, 2, 2 }, -- extra window padding [top, right, bottom, left]
    },
    layout = {
        height = { min = 4, max = 25 }, -- min and max height of the columns
        width = { min = 20, max = 50 }, -- min and max width of the columns
        spacing = 3, -- spacing between columns
    },
    hidden = { '<silent>', '<cmd>', '<Cmd>', '<CR>', 'call', 'lua', '^:', '^ ' }, -- hide mapping boilerplate
    show_help = false, -- show help message on the command line when the popup is visible
})

---- Set leader
vim.api.nvim_set_keymap('n', '<Space>', '<NOP>', { noremap = true, silent = true })
-- TODO create entire treesitter section

local opts = {
    mode = 'n', -- NORMAL mode
    prefix = '<leader>',
    buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
    silent = true, -- use `silent` when creating keymaps
    noremap = true, -- use `noremap` when creating keymaps
    nowait = false, -- use `nowait` when creating keymaps
}

local mappings = {
    ['/'] = 'Comment',
    ['c'] = 'Close Buffer',
    ['e'] = 'Explorer',
    ['h'] = 'No Highlight',
    s = {
        name = '+Search',
        b = { '<cmd>Telescope git_branches<cr>', 'Checkout branch' },
        c = { '<cmd>Telescope colorscheme<cr>', 'Colorscheme' },
        d = { '<cmd>Telescope lsp_document_diagnostics<cr>', 'Document Diagnostics' },
        D = { '<cmd>Telescope lsp_workspace_diagnostics<cr>', 'Workspace Diagnostics' },
        f = { '<cmd>Telescope find_files<cr>', 'Find File' },
        m = { '<cmd>Telescope marks<cr>', 'Marks' },
        M = { '<cmd>Telescope man_pages<cr>', 'Man Pages' },
        r = { '<cmd>Telescope oldfiles<cr>', 'Open Recent File' },
        R = { '<cmd>Telescope registers<cr>', 'Registers' },
        t = { '<cmd>Telescope live_grep<cr>', 'Text' },
    },
    d = {
        name = '+Diagnostics',
        t = { '<cmd>TroubleToggle<cr>', 'trouble' },
        w = { '<cmd>TroubleToggle lsp_workspace_diagnostics<cr>', 'workspace' },
        d = { '<cmd>TroubleToggle lsp_document_diagnostics<cr>', 'document' },
        q = { '<cmd>TroubleToggle quickfix<cr>', 'quickfix' },
        l = { '<cmd>TroubleToggle loclist<cr>', 'loclist' },
        r = { '<cmd>TroubleToggle lsp_references<cr>', 'references' },
    },
    S = {
        name = '+Session',
        s = { '<cmd>SessionSave<cr>', 'Save Session' },
        l = { '<cmd>SessionLoad<cr>', 'Load Session' },
    },
}

local wk = require('which-key')
Nnoremap('<Space>wk', ':WhichKey', { silent = true })
wk.register(mappings, opts)
