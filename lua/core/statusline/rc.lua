DefaultHlRange = {
    Normal = "red",
    Visual = "green",
    Insert = "orange",
    Command = "green",
    Replace = "cyan"
}

DefaultModeIcons = {
    Normal = "",
    Visual = "",
    Insert = "",
    Command = "",
    Replace = ""
}

local colorscheme = import("colorscheme")
local dset = function(s, c)
    assert(s ~= nil, "sign must not be empty")
    return {
        sign = s,
        color = c
    }
end
CONFIG = {
    padding = 2,
    icons = {},
    os = "UNIX",
    colorscheme = colorscheme["gruvbox"],
    diagnostic = {
        error = dset("", "red"),
        info = dset("", "darkblue"),
        warn = dset("", "orange"),
        hint = dset("??", "light_purple")
    },
    mode = {
        highlight_range = DefaultHlRange,
        icons = DefaultModeIcons
    }
}

return CONFIG
