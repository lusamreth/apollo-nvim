local helpers = access_module('nv-tree.helpers')

-- user config
local tree_config = {
    -- setting relating to netrw
    netrw = {
        disable_netrw = true,
        hijack_netrw = true,
        hijack_cursor = true,
    },
    enable = true,
    ignore_ft_on_setup = { 'dashboard' },
    -- setting relating to directory
    dir = {
        change_cwd = true, -- change dir when cd
        hide_dotfiles = true,
        root_folder_modifier = ':t',
        highlight_opened_files = true,
        indent_markers = 1,
    },
    behavoirs = {
        lsp_diagnostics = true,
        auto_open = 0,
        auto_close = 1,
        tab_open = 0,
        update_focused_file = {
            enable = 1,
        },
        show_icons = {
            git = 1,
            folders = 1,
            files = 1,
            folder_arrows = 1,
            tree_width = 30,
        },
    },
    icons = {
        default = '',
        symlink = '',
        git = {
            unstaged = '✗',
            staged = '✓',
            unmerged = '',
            renamed = '➜',
            untracked = '★',
        },
        folder = {
            default = '',
            open = '',
            empty = '',
            empty_open = '',
            symlink = '',
            symlink_open = '',
        },
        lsp = {
            hint = '',
            info = '',
            warning = '',
            error = '',
        },
    },
    filters = {
        show_hidden = true,
    },
    keybinds = nil, -- utilize default
    hooks = {
        -- store a bunch of closure
        open = {
            -- order is important
            helpers.hlconfig,
            helpers.extend_bufferline,
        },
        close = {},
    },
    sort = {
        sorter = 'case_sensitive',
    },
    view = {
        allow_resize = true,
        side = 'left',
        width = 25,
    },
}

return tree_config
