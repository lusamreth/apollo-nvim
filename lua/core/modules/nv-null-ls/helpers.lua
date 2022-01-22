local M = {}

function M.BuiltinFactory(builtin_list, category_name, ManualHandler)
    local category = require('null-ls').builtins[category_name]

    -- local aucon = spawner.CreateAutoConverter()
    local Mhandle = ManualHandler()

    local function process_table(ftb)
        if ftb['manual'] then
            -- aucon.ConvertToAuto(ftb)
            Mhandle.handle(ftb)
            return
        else
            local builtin = category[ftb['name']]
            -- print('NAME', ftb['name'], category_name, vim.inspect(builtin_list))
            local config = ftb['config'] or {}
            return builtin.with(config)
        end
    end

    return function()
        local sources = {}
        -- aucon.build()
        for _, format in pairs(builtin_list) do
            local builtin
            if type(format) == 'table' then
                builtin = process_table(format)
            else
                builtin = category[format]
            end
            table.insert(sources, builtin)
        end

        Mhandle.build()
        return sources
    end
end

function M.MakeInterceptor(pattern)
    return function(data, capture)
        local find_match = string.gmatch(data, pattern)
        if find_match() then
            capture(vim.split(data, '\n'), true)
        end
    end
end
return M
