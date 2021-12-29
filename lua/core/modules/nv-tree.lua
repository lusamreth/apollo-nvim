local opt = vim
local g = opt.g

opt.o.termguicolors = true
-- g.nvim_tree_add_trailing = 0 -- append a trailing slash to folder names
-- g.nvim_tree_allow_resize = 1
-- g.nvim_tree_auto_close = 0 -- closes tree when it's the last window
-- g.nvim_tree_auto_ignore_ft = {"dashboard"} -- don't open tree on specific fiypes.
-- g.nvim_tree_auto_open = 0
-- g.nvim_tree_disable_netrw = 1
-- g.nvim_tree_follow = 1
-- g.nvim_tree_git_hl = 1
-- g.nvim_tree_gitignore = 1
-- g.nvim_tree_hide_dotfiles = 0
-- g.nvim_tree_highlight_opened_files = 0
-- g.nvim_tree_hijack_netrw = 0
-- g.nvim_tree_indent_markers = 1
-- g.nvim_tree_ignore = {".git", "node_modules", ".cache"}
-- g.nvim_tree_quit_on_open = 1 -- closes tree when file's opened
-- g.nvim_tree_root_folder_modifier = table.concat {":t:gs?$?/..", string.rep(" ", 1000), "?:gs?^??"}
-- g.nvim_tree_side = "left"
-- g.nvim_tree_tab_open = 0
-- g.nvim_tree_update_cwd = 1
-- g.nvim_tree_width = 25
-- g.nvim_tree_lsp_diagnostics = 0
-- g.nvim_tree_show_icons = {
--     git = 1,
--     folders = 1,
--     files = 1
-- }

-- g.nvim_tree_icons = {
--     default = "",
--     symlink = "",
--     git = {
--         unstaged = "✗",
--         staged = "✓",
--         unmerged = "",
--         renamed = "➜",
--         untracked = "★"
--     },
--     folder = {
--         default = "",
--         open = "",
--         empty = "",
--         empty_open = "",
--         symlink = "",
--         symlink_open = ""
--     }
-- }

local firstrun = 0
vim.cmd("set termguicolors")
local hiTreeFolder = function(treetype, col)
    local hi = string.format("hi NvimTreeFolder%s guifg=%s", treetype, col)
    vim.cmd(hi)
end

local hlconfig = function()
    if firstrun > 0 then
        return
    else
        -- if colorscheme is use will be override
        hiTreeFolder("Icon", "#51afef")
        hiTreeFolder("Name", "#ec5f67")
        hiTreeFolder("ImageFile", "#p25f67")
        hiTreeFolder("OpenedFolderName", "#111111")
        hiTreeFolder("Marker", "#p25f67")
    end
    firstrun = 1
end

local extend_bufferline = function()
    if package.loaded["bufferline.state"] then
        require("bufferline.state").set_offset(30 + 1, "")
    end
end
-- Mappings for nvimtree
function CustomTreeToggle()
    local success, _ = pcall(hlconfig, nil)
    assert(success, "Failed on opening tree hook!")
    opt.cmd("NvimTreeToggle")
end

local function tree_hook(h)
    local function runhook(kind)
        local hk = h[kind]
        assert(hk ~= nil, "Unavialable hook!")
        if #hk == 0 then
            return
        end
        for name, hookfn in pairs(hk) do
            local success, _ = pcall(hookfn, nil)
            assert(success, "Failed on opening tree hook! name : [" .. name .. "]")
            hookfn()
        end
    end

    Caller =
        Gbinder.bind(
        function()
            return runhook("close")
        end
    )

    vim.cmd "au WinClosed * lua Caller()"
    return function()
        runhook("open")
        vim.cmd("NvimTreeToggle")
    end
end

local function loadtree(mod)
    if mod then
        mod = "." .. mod
    else
        mod = ""
    end

    local status_ok, res = pcall(require, "nvim-tree" .. mod)
    if not status_ok then
        print("CANNOT LOAD NVIMTREE!.. won't able to access convenient folders drawers")
        return
    end
    return res
end

local nvim_tree_config = loadtree("config")
local function default_tree_binds()
    local tree_cb = nvim_tree_config.nvim_tree_callback
    vim.g.nvim_tree_bindings = {
        {key = {"<CR>", "o", "<2-LeftMouse>"}, cb = tree_cb("edit")},
        {key = {"<2-RightMouse>", "<C-]>"}, cb = tree_cb("cd")},
        -- window navigation
        {key = "<C-v>", cb = tree_cb("vsplit")},
        {key = "<C-x>", cb = tree_cb("split")},
        {key = "<C-t>", cb = tree_cb("tabnew")},
        -- Node navigation
        {key = "<", cb = tree_cb("prev_sibling")},
        {key = ">", cb = tree_cb("next_sibling")},
        {key = "P", cb = tree_cb("parent_node")},
        {key = "<BS>", cb = tree_cb("close_node")},
        {key = "<S-CR>", cb = tree_cb("close_node")},
        {key = "<Tab>", cb = tree_cb("preview")},
        {key = "K", cb = tree_cb("first_sibling")},
        {key = "J", cb = tree_cb("last_sibling")},
        -- toggler
        {key = "I", cb = tree_cb("toggle_ignored")},
        {key = "H", cb = tree_cb("toggle_dotfiles")},
        -- basic operations
        {key = "R", cb = tree_cb("refresh")},
        {key = "a", cb = tree_cb("create")},
        {key = "d", cb = tree_cb("remove")},
        {key = "r", cb = tree_cb("rename")},
        {key = "<C-r>", cb = tree_cb("full_rename")},
        -- copy,paste,cut
        {key = "x", cb = tree_cb("cut")},
        {key = "c", cb = tree_cb("copy")},
        {key = "p", cb = tree_cb("paste")},
        {key = "y", cb = tree_cb("copy_name")},
        {key = "Y", cb = tree_cb("copy_path")},
        {key = "gy", cb = tree_cb("copy_absolute_path")},
        -- git related
        {key = "[c", cb = tree_cb("prev_git_item")},
        {key = "]c", cb = tree_cb("next_git_item")},
        {key = "-", cb = tree_cb("dir_up")},
        {key = "s", cb = tree_cb("system_open")},
        {key = "q", cb = tree_cb("close")},
        {key = "g?", cb = tree_cb("toggle_help")}
    }
end

-- user config
local tree_config = {
    -- setting relating to netrw
    netrw = {
        disable_netrw = true,
        hijack_netrw = true,
        hijack_cursor = true
    },
    enable = true,
    ignore_ft_on_setup = {"dashboard"},
    -- setting relating to directory
    dir = {
        change_cwd = true, -- change dir when cd
        hide_dotfiles = true,
        root_folder_modifier = ":t",
        highlight_opened_files = true,
        indent_markers = 1
    },
    behavoirs = {
        lsp_diagnostics = true,
        auto_open = 0,
        auto_close = 1,
        tab_open = 0,
        update_focused_file = {
            enable = 1
        },
        show_icons = {
            git = 1,
            folders = 1,
            files = 1,
            folder_arrows = 1,
            tree_width = 30
        }
    },
    icons = {
        default = "",
        symlink = "",
        git = {
            unstaged = "✗",
            staged = "✓",
            unmerged = "",
            renamed = "➜",
            untracked = "★"
        },
        folder = {
            default = "",
            open = "",
            empty = "",
            empty_open = "",
            symlink = "",
            symlink_open = ""
        },
        lsp = {
            hint = "",
            info = "",
            warning = "",
            error = ""
        }
    },
    keybinds = nil, -- utilize default
    hooks = {
        -- store a bunch of closure
        open = {
            -- order is important
            hlconfig,
            extend_bufferline
        },
        close = {}
    },
    view = {
        allow_resize = true,
        side = "left",
        width = 25
    }
}

import("utility.binding")
local function process_nv_tree(cfg)
    local treecfg = {}
    local tree_k = function(m)
        return "nvim_tree_" .. m
    end

    if cfg["enable"] == false then
        return
    end

    Toggler = "NvimTreeToggle"

    local cus = cfg["hooks"]
    if cus then
        F = tree_hook(cus)
        Toggler = "lua " .. "F()"
    end

    if cfg["keybinds"] == nil then
        default_tree_binds()
    end

    Nnoremap("<C-n>", Toggler, {})
    table.insert(treecfg, cfg["behavoirs"])
    treecfg["view"] = cfg["view"]
    g[tree_k("icons")] = cfg["icons"]

    for name, e in pairs(cfg["dir"]) do
        g[tree_k(name)] = e
    end

    loadtree().setup(treecfg)
end
process_nv_tree(tree_config)
