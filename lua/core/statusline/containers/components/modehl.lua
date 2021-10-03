M = {}

local m = import("bedrock.data-access.adapters.custom")
local colors = {}

HlRange, ModeIcons = {}, {}

function M.getmodeicon(data)
    local i = m.request_mode_group(data)
    return ModeIcons[i]
end

local function setbg()
    local u = function()
        local i = m.request_mode_group(m.get_mode())
        return {
            bg = colors[HlRange[i]],
            fg = "white"
        }
    end
    return u
end

local function setfg(bg)
    return function()
        if type(bg) == "function" then
            bg = bg()
        end
        local u = function()
            local i = m.request_mode_group(m.get_mode())
            return {
                fg = colors[HlRange[i]],
                bg = bg
            }
        end
        return u
    end
end

M.config = function(col, conf)
    colors = col
    HlRange = conf["highlight_range"]
    ModeIcons = conf["icons"]
    return M
end

-- dynhl : creating and bind addrs to hl
-- getdynbg : bg that dynamically change from other linked comps
-- conf : configuration requirement !
M.dynhl = function(dynhl, getdynbg)
    local modehl = dynhl.create_dynamic_hl(setbg)
    local preserve_bg = dynhl.create_dynamic_hl(setfg(getdynbg))
    return {
        padding = preserve_bg,
        main = modehl
    }
end

return M
