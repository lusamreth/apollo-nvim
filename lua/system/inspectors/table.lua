local function readonly_newindex(_, _, _)
    error('You cannot make any changes to this table!', 1)
end

function table.freeze(tbl)
    return setmetatable(tbl, {
        __index = tbl,
        __newindex = readonly_newindex,
    })
end

local original_pairs = pairs

function table.pairs(tbl)
    if next(tbl) == nil then
        local mt = getmetatable(tbl)
        if mt and mt.__newindex == readonly_newindex then
            tbl = mt.__index
        end
    end
    return original_pairs(tbl)
end

function table.splice(tbl, start, length)
    length = length or 1
    start = start or 1
    local endd = start + length
    local spliced = {}
    local remainder = {}
    for i, elt in ipairs(tbl) do
        if i < start or i >= endd then
            table.insert(spliced, elt)
        else
            table.insert(remainder, elt)
        end
    end
    return spliced, remainder
end

-- copied from xlua support printing table
function table.printf(obj, ...)
    if type(obj) == 'table' then
        local mt = getmetatable(obj)
        if mt and mt.__tostring__ then
            io.write(mt.__tostring__(obj))
        else
            local tos = tostring(obj)
            local obj_w_usage = false
            if tos and not string.find(tos, 'table: ') then
                if obj.usage and type(obj.usage) == 'string' then
                    io.write(obj.usage)
                    io.write('\n\nFIELDS:\n')
                    obj_w_usage = true
                else
                    io.write(tos .. ':\n')
                end
            end
            io.write('{')
            local tab = ''
            local idx = 1
            for k, v in pairs(obj) do
                if idx > 1 then
                    io.write(',\n')
                end
                if type(v) == 'userdata' then
                    io.write(tab .. '[' .. k .. ']' .. ' = <userdata>')
                else
                    local tostr = tostring(v):gsub('\n', '\\n')
                    if #tostr > 40 then
                        local tostrshort = tostr:sub(1, 40)
                        io.write(tab .. '[' .. tostring(k) .. ']' .. ' = ' .. tostrshort .. ' ... ')
                    else
                        io.write(tab .. '[' .. tostring(k) .. ']' .. ' = ' .. tostr)
                    end
                end
                tab = ' '
                idx = idx + 1
            end
            io.write('}')
            if obj_w_usage then
                io.write('')
            end
        end
    else
        io.write(tostring(obj))
    end
    if select('#', ...) > 0 then
        io.write('    ')
        print(...)
    else
        io.write('\n')
    end
end

function table.unwrap_print(tab, pad)
    pad = pad or '|'
    for name, val in pairs(tab) do
        print('\n')
        print(pad, name, '==>', val)
        if type(val) == 'table' then
            table.unwrap_print(val, pad .. '->')
        end
    end
end

_G.printf = printf
