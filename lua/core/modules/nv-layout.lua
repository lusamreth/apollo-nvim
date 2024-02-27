vim.g.symbols_outline = {
    highlight_hovered_item = true,
    show_guides = true,
    auto_preview = true, -- experimental
    position = 'left',
    keymaps = {
        close = '<Esc>',
        goto_location = '<Cr>',
        focus_location = 'o',
        hover_symbol = '<C-space>',
        rename_symbol = 'r',
        code_actions = 'a',
    },
    lsp_blacklist = {},
}

-- still buggy
--Nnoremap(",o","SymbolsOutline",{silent = true})

vim.g.indent_blankline_enabled = true
vim.g.indentLine_fileTypeExclude = { 'dashboard' }

-- http://lua-users.org/wiki/FileInputOutput

-- see if the file exists
function file_exists(file)
    local f = io.open(file, 'rb')
    if f then
        f:close()
    end
    return f ~= nil
end

-- get all lines from a file, returns an empty
-- list/table if the file does not exist
function lines_from(file)
    if not file_exists(file) then
        return {}
    end
    lines = {}
    for line in io.lines(file) do
        lines[#lines + 1] = line
    end
    return lines
end

-- tests the functions above
local file = '/home/lusamreth/diablo-head.txt'
local lines = lines_from(file)

require('utility.var')
--vim.g.dashboard_custom_header = lines

local home = os.getenv('HOME')
local dashboard = require('dashboard')
--
dashboard.preview_file_height = 11
dashboard.preview_file_width = 70

dashboard.custom_header = PUFFYBOI
-- db.preview_command = 'chafa'

dashboard.custom_center = {
    { icon = '  ', desc = 'Recently latest session                  ', shortcut = 'SPC s l', action = 'SessionLoad' },
    { icon = '  ', desc = 'Recently opened files                   ', action = 'DashboardFindHistory', shortcut = 'SPC f h' },
    { icon = '  ', desc = 'Find  File                              ', action = 'Telescope find_files find_command=rg,--hidden,--files', shortcut = 'SPC f f' },
    { icon = '  ', desc = 'File Browser                            ', action = 'Telescope file_browser', shortcut = 'SPC f b' },
    { icon = '  ', desc = 'Find  word                              ', action = 'Telescope live_grep', shortcut = 'SPC f w' },
    { icon = '  ', desc = 'Open Personal dotfiles                  ', action = 'Telescope dotfiles path=' .. home .. '/.dotfiles', shortcut = 'SPC f d' },
}

dashboard.setup({
    theme = 'doom',
    config = {
        header = PUFFYBOI, --your header
        project = { enable = true, limit = 8, icon = 'your icon', label = '', action = 'Telescope find_files cwd=' },
        center = {
            {
                icon = ' ',
                icon_hl = 'Title',
                desc = 'Find File           ',
                desc_hl = 'String',
                keymap = ', f f',
                key_hl = 'Number',
                key_format = ' %s', -- remove default surrounding `[]`
                action = 'Telescope find_files cwd=',
            },
            {
                icon = ' ',
                icon_hl = 'Title',
                desc = 'Harpoon Regisgry',
                desc_hl = 'String',
                keymap = 'hf',
                key_hl = 'Number',
                key_format = ' %s', -- remove default surrounding `[]`
                action = 'Telescope find_files cwd=',
            },
        },
        footer = {}, --your footer
    },
})
