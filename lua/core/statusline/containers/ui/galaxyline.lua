GLS = {}
LINKED = 'COUPLE'

local u = import('drivers.lib').uniq
local nest = import('drivers.lib').nest

local gls = require('galaxyline').section
ComponentStack = {
    pos = {},
    sections = {},
}

local function get_pIndex(pos)
    local pIndex = ComponentStack['pos'][pos] or 0
    return pIndex
end
-- each gls operation work through a single component
GLS.draw = function(section, pos)
    assert(type(section) == 'table', debug.traceback('TRACKED'))
    local i = 1
    local function set(s)
        -- ComponentStacks["sections"]

        -- update the position
        ComponentStack['pos'][pos] = i + get_pIndex(pos)
        gls[pos][get_pIndex(pos)] = s
    end
    -- if #section == 1 then
    --     set(section[1])
    --     return
    -- end

    for _, inner in pairs(section) do
        set(inner)
    end
end

local function handle_link_comp(linked, unwrap)
    local function link_id()
        return u.get_id('LINK_COMP')
    end

    local res = {}
    for i, comp in pairs(linked) do
        local id = link_id()
        res[i] = nest(id, unwrap(comp))
    end
    return res
end

-- convert response model to gls object
GLS.convert = function(nested_comp, condition)
    local k = u.get_key(nested_comp)
    local component = nested_comp[k]

    -- print("LECOMP", component["provider"])
    local function unwrap_comp(comp)
        assert(type(comp) == 'table', debug.traceback('TRACE'))
        local o = {}
        o['condition'] = condition
        local keys = { 'provider', 'highlight', 'seperator' }
        for _, key in pairs(keys) do
            o[key] = comp[key]
        end

        return o
    end

    if k == LINKED then
        return handle_link_comp(component, unwrap_comp)
    else
        return {
            nest(k, unwrap_comp(component)),
        }
    end
end

GLS.gls = gls
return GLS
