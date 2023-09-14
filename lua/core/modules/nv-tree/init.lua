import('utility.binding')

local opt = vim
local g = opt.g
local kbs = access_module('nv-tree.default-keybinds')
local helpers = access_module('nv-tree.helpers')
local user_config = access_module('nv-tree.config')

opt.o.termguicolors = true
local firstrun = 0

vim.cmd('set termguicolors')

local function loadtree(mod)
    if mod then
        mod = '.' .. mod
    else
        mod = ''
    end

    local status_ok, res = pcall(require, 'nvim-tree' .. mod)
    if not status_ok then
        print("cannot load nvimtree!.. won't able to access convenient folders drawers")
        return
    end
    return res
end

local function process_nv_tree_cfg(cfg)
    local treecfg = {}
    local tree_k = function(m)
        return 'nvim_tree_' .. m
    end

    if cfg['enable'] == false then
        return
    end

    local toggler = 'NvimTreeToggle'
    local hooks = cfg['hooks']
    if hooks then
        f = helpers.tree_hook(hooks)
        toggler = 'lua ' .. 'f()'
    end

    if cfg['keybinds'] == nil then
        -- default_tree_binds()
        table.insert(treecfg, {
            on_attach = function(bufnr)
                kbs.default_nvtree_keybinds(bufnr)
            end,
        })
    end

    table.insert(treecfg, cfg['behavoirs'])
    treecfg['view'] = cfg['view']
    g[tree_k('icons')] = cfg['icons']
    for name, e in pairs(cfg['dir']) do
        g[tree_k(name)] = e
    end

    Nnoremap('<C-n>', toggler, {})

    return treecfg
end

loadtree().setup(process_nv_tree_cfg(user_config))
