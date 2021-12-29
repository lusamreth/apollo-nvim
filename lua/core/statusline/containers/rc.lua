local colorscheme = require("core.colorscheme")
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
    colorscheme = colorscheme,
    diagnostic = {
        error = dset("", "red"),
        info = dset("", "darkblue"),
        warn = dset("", "orange"),
        hint = dset("??", "light_purple")
    }
}

return CONFIG
