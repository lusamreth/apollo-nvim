M = {}

function M.InContainer(m)
    return import(m, STATUSLINE_ROOT .. 'containers/')
end

function M.InBedrock(m)
    return import(m, BEDROCK_ROOT)
end

local uniq = import('bedrock.drivers.lib').uniq
function M.check_if_coupling(rl)
    return rl[LINKED] ~= nil
end

function M.stamp(c)
    local stp = uniq.get_id('chain')
    local temp = {
        [stp .. 'temp_nest'] = c,
    }
    return temp
end

return M
