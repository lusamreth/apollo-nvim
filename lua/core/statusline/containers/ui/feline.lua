local FEL = {}
local feline_components = {
    active = {},
    inactive = {}
}

local u = import("bedrock.drivers.lib").uniq
local DynHL = import("containers.ui.hl-helpers")

for _, i in pairs({1, 2, 3}) do
    feline_components["inactive"][i] = {}
    feline_components["active"][i] = {}
end

local function translate(pos)
    local pos_table = {
        left = 1,
        right = 3,
        mid = 2
    }
    if pos_table[pos] == nil then
        error("INVALID position :", pos)
    end
    local fpos = pos_table[pos]
    return fpos
end

-- DEFAULT PROVIDER
-- vi_mode	Current vi_mode
-- position	Get line and column number of cursor
-- line_percentage	Current line percentage
-- scroll_bar	Scroll bar that shows file progress
-- file_info	Get file icon, name and modified status
-- file_size	Get file size
-- file_type	Get file type
-- file_encoding	Get file encoding
-- git_branch	Shows current git branch
-- git_diff_added	Git diff added count
-- git_diff_removed	Git diff removed count
-- git_diff_changed	Git diff changed count
-- lsp_client_names	Name of LSP clients attached to current buffer
-- diagnostic_errors	Diagnostics errors count
-- diagnostic_warnings	Diagnostics warnings count
-- diagnostic_hints	Diagnostics hints count
-- diagnostic_info	Diagnostics info count

local DEFAULT_PROVIDER = {
    "vi_mode",
    "position",
    "line_percentage",
    "scroll_bar",
    "file_info",
    "file_size",
    "file_type"
}

FEL.init = function()
    require("feline").setup(
        {
            components = feline_components
        }
    )
end

local function check_default_provider(provider)
    assert(type(provider) == "function", type(provider))

    local p = function()
        return provider()
    end

    local stat, res = pcall(provider, nil)
    assert(stat == true, res)
    if type(res) == "string" then
        local r
        for _, pro in pairs(DEFAULT_PROVIDER) do
            if res == pro then
                r = pro
            end
        end
        if r == nil then
            return p
        end
        return r
    else
        return p
    end
end

-- 1 : left, 2 : mid , 3 : right
FEL.draw = function(section, pos)
    local fpos

    fpos = pos
    if type(pos) == "string" then
        fpos = translate(pos)
    end

    local i = 1
    local function set(s)
        -- update the position
        table.insert(feline_components["active"][fpos], s)
        --feline_components["active"][fpos][i] = s
    end
    for _, inner in pairs(section) do
        set(inner)
        i = i + 1
    end
end

local function handle_link_comp(linked, unwrap)
    local res = {}
    for i, comp in pairs(linked) do
        res[i] = unwrap(comp)
    end

    return res
end

FEL.capabilities = {
    DynHL = {
        enable = false,
        instances = {},
        addrs = {}
    }
}

FEL.create_dynamic_hl = function(f)
    FEL.capabilities.DynHL["enable"] = true
    local h = DynHL.init(f)

    return h
end

FEL.bind = function(comp, inst)
    local k = u.get_key(comp)
    -- add on addrs
    comp[k]["addrs"] = k
    FEL.capabilities["DynHL"]["instances"][k] = inst
end
-- example
-- caps = {
--  DynHL = {
--    enabled = true,
--    instances = {(Cname,DynHLObj)}
--  }
-- }

local function extend_cap(k, obj)
    for _, capability in pairs(FEL.capabilities) do
        if capability["enable"] then
            if capability["instances"][k] ~= nil then
                local c = capability["instances"][k].context(obj)
                obj["hl"] = c
            end
        -- internal mutation !!
        end
    end

    return obj
end

FEL.convert = function(nested_comp, condtion)
    local k = u.get_key(nested_comp)
    local component = nested_comp[k]

    local function unwrap(comp)
        assert(type(comp) == "table", component)

        local fel_obj = {}
        local p = check_default_provider(comp["provider"])
        fel_obj["provider"] = p
        local hl = comp["highlight"]

        fel_obj["hl"] = {
            fg = hl[1],
            bg = hl[2]
        }

        if comp["addrs"] ~= nil then
            fel_obj = extend_cap(comp["addrs"], fel_obj)
        end

        fel_obj["enabled"] = condtion or nil
        return fel_obj
    end
    if k == LINKED then
        return handle_link_comp(component, unwrap)
    else
        return {
            unwrap(component)
        }
    end
end

return FEL
