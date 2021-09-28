UI_USECASE = {}

-- How to present the data
-- formatter has ability to mutate data
-- FORMATTER = {
--     function with one parameter and that must include in
--     return otherwise will not display data
--
--     filename = function(data)
--     if data == "" then ... end
--        string.format("%s %s",data,icons)
--     end,
--     line_pos,
--     vimode
--     vcs,
--     filename
-- }

-- NEOVIM DATA : data_access
-- --> gateway<I> --> data-provider(in this example
-- it is the same as galaxyline). Some more lightweight
-- statusline don't have this builtin
--

SCHEMA = import("bedrock.domain")
local identifier = import("bedrock.usecases.identifier")
local h = import("bedrock.usecases.helpers")

UI_USECASE.nester = identifier.Nester:init(UI_USECASE)
UI_USECASE.nest = UI_USECASE.nester.nest

local uniq = identifier.Identifier:init(UI_USECASE)
UI_USECASE.uniq = uniq

local RETURN_COMPONENT = "table"
local HIGHLIGHT = {"table", "->", RETURN_COMPONENT}

local default_color_check = h.default_color_check
local generic_comp = h.generic_comp

I = {
    {"vcs_icon", HIGHLIGHT},
    {"line_position", HIGHLIGHT},
    {"page_position", HIGHLIGHT},
    {"vimode_indicator", HIGHLIGHT},
    -- {"filesize", {{"string", "table"}, "->", "table"}},
    {"filesize", HIGHLIGHT},
    {"filename", HIGHLIGHT},
    {
        "diagnostic",
        {
            "string",
            "->",
            RETURN_COMPONENT
        }
    }
}

local format = function(fn, k)
    if UI_USECASE.formatters[k] ~= nil then
        --print("OOOF form", k, UI_USECASE["formatters"][k])
        --> will produce function for dynamic component
        return function()
            local f = fn()
            return UI_USECASE["formatters"][k](f)
        end
    else
        return fn
    end
end

UIPORT = interface.build_interface(I)

UI_USECASE.build_vcs_icon = function(vcs_provider, cols)
    return function(hi)
        local vcs = vcs_provider
        local icon
        if vcs.get_workspace == "git" then
            icon = ""
        end

        local branch = function()
            if icon ~= nil then
                return icon .. vcs.get_branch()
            else
                return vcs.get_branch()
            end
        end
        -- just mock must be changed
        local hl = default_color_check(hi, cols)
        local vcs_id = UI_USECASE.uniq.get_id("vcs")

        -- if formatter exist override
        if UI_USECASE.formatters["vcs"] ~= nil then
            branch = format(vcs.get_branch, "vcs")
        end

        return UI_USECASE.nest(vcs_id, SCHEMA.make_component(branch, hl))
    end
end

UI_USECASE.build_line_position = function(nvim_provider, cols)
    local fn = format(nvim_provider.get_line_position, "line_position")
    return generic_comp("line_pos", fn, cols)
end

UI_USECASE.build_page_position = function(nvim_provider, cols)
    local fn = format(nvim_provider.get_page_position, "page_position")
    return generic_comp("page_pos", fn, cols)
end

-- bound : must convert b to kb
-- counld cover file-type

-- I dont wanna see bytes
UI_USECASE.build_filesize = function(file_provider, cols)
    return function(hl)
        local function converter()
            local s = file_provider.get_filesize()
            local unit = s:sub(#s - 1, #s)
            if s == "" then
                return "NULL"
            end

            if unit == "b" then
                local kb_size = tonumber(s:sub(1, #s - 2)) / 1000
                return kb_size .. "kb"
            else
                return s
            end
        end

        local f_id = UI_USECASE.uniq.get_id("filesize")
        hl = default_color_check(hl, cols)
        local f = format(converter, "filesize")
        return UI_USECASE.nest(f_id, SCHEMA.make_component(f, hl))
    end
end

UI_USECASE.build_filename = function(file_provider, cols)
    local fn = file_provider.get_filename
    return generic_comp("filename", format(fn, "filename"), cols)
end

UI_USECASE.build_vimode_indicator = function(nvim_provider, cols)
    return function(hi)
        local m = nvim_provider.getmode
        local hl = default_color_check(hi, cols)
        m = format(m, "vimode")
        return UI_USECASE.nest(UI_USECASE.uniq.get_id("nvim_mode"), SCHEMA.make_component(m, hl))
    end
end

-- 
-- 
-- 
-- 

-- errorindc = {
--  sign = cross,
--  color = red
-- }

-- errorindc --> [[ drivers ]] --> nest([[ component ]])
DIAG =
    interface.build_interface(
    {
        {"get_diagnostic_hint", {"->", "number"}},
        {"get_diagnostic_error", {"->", "number"}},
        {"get_diagnostic_warn", {"->", "number"}},
        {"get_diagnostic_info", {"->", "number"}}
    }
)

-- every serverity is color coded
-- return an array of components
UI_USECASE.build_diagnostic = function(diag_driver, cols)
    local providers = DIAG.build(diag_driver)
    --local providers = diag_driver
    return function(bg, indicators)
        local dgs = {}
        for d_type, indc in pairs(indicators) do
            local c = indc["color"] or cols.fg
            local sign = indc["sign"]
            print("ouu sign", sign)
            assert(sign ~= nil, "indicators must has a specific sign")

            local f = providers["get_diagnostic_" .. d_type]
            if f == nil then
                error("diagnostic_type " .. d_type .. "is not supported")
            end

            local pro = function()
                local count = f()
                return count ~= 0 and sign .. " " .. count .. " " or ""
            end
            local hi = {
                fg = c,
                bg = bg or cols.bg
            }

            local hl = default_color_check(hi, cols)
            table.insert(dgs, SCHEMA.make_component(pro, hl))
        end
        return UI_USECASE.nest(LINKED, dgs)
        --return dgs
    end
end

return {UIPORT, UI_USECASE}
