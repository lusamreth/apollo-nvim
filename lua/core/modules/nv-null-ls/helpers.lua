local M = {}

access_module('nv-null-ls.custom')

function M.BuiltinFactory(builtin_list, category_name)
    local custom_fmt = BuildCustomFormatter()
    local category = require('null-ls').builtins[category_name]

    local aucon = custom_fmt
    local function process_table(ftb)
        if ftb['manual'] then
            local cfg = ftb['config']
            -- lazy_loading('xml')
            return aucon(cfg)
        else
            local builtin = category[ftb['name']]
            local config = ftb['config'] or {}
            return builtin.with(config)
        end
    end

    return function()
        local sources = {}
        for _, format in pairs(builtin_list) do
            local builtin
            if type(format) == 'table' then
                builtin = process_table(format)
            else
                builtin = category[format]
            end
            table.insert(sources, builtin)
        end

        -- aucon.build()
        return sources
    end
end

return M
