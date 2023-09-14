_G.__luacache_config = {
    chunks = {
        enable = true,
        path = vim.fn.stdpath('cache') .. '/luacache_chunks',
    },
    modpaths = {
        enable = true,
        path = vim.fn.stdpath('cache') .. '/luacache_modpaths',
    },
}

HOMEROOT = '/home/lusamreth'

_G.HOMEROOT = HOMEROOT
_G.LUAROOT = HOMEROOT .. '/.config/nvim/lua'

local import = function(mod, root, use_require)
    -- use_require = true
    if use_require then
        return require(mod)
    end
    -- print("importing", mod)
    root = root or LUAROOT .. '/'
    -- bug cannot use vim.split
    local succ, res = pcall(Splitstr, mod, '.')

    if succ == true then
        local full = ''
        for i, p in pairs(res) do
            local suffix = '/'
            if i == #res then
                suffix = ''
            end
            full = full .. p .. suffix
        end
        mod = full
    end
    local f, e = loadfile(root .. mod .. '.lua')
    if e then
        error('has error importing\n' .. e)
    end
    return f()
end

_G.import = import
local original_import = import

_G.reset_import = function()
    _G.import = original_import
end

_G.make_import = function(root)
    return function(mod)
        return import(mod, root)
    end
end

function _G.access_core(mod, dir)
    dir = dir or '/.config/nvim'
    return import(mod, '/home/lusamreth/' .. dir .. '/lua/core/')
end

function _G.access_module(mod)
    return _G.access_core('modules.' .. mod)
end

function _G.access_system(mod)
    return import('system.' .. mod)
end
