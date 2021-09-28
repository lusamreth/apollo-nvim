M = {}

local m = import("bedrock.data-access.adapters.custom")
local n = {}

local mode_hl_range = {
    NORMAL = "red",
    VISUAL = "green",
    INSERT = "orange",
    COMMAND = "green",
    REPLACE = "cyan"
}

local function setbg()
    local u = function()
        local i = m.get_mode()
        return {
            bg = n[mode_hl_range[i]],
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
            local i = m.get_mode()
            return {
                fg = n[mode_hl_range[i]],
                bg = bg
            }
        end
        return u
    end
end

M.config = function(dynhl, colorscheme, getdynbg)
    n = colorscheme
    local modehl = dynhl.create_dynamic_hl(setbg)
    local preserve_bg = dynhl.create_dynamic_hl(setfg(getdynbg))
    return {
        padding = preserve_bg,
        main = modehl
    }
end

return M
