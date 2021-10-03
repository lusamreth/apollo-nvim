local gruvbox = {
    orange = "#d65d0e",
    white = "#ffffff",
    cyan = "#008080",
    red = "#ec5f67",
    nord = "#458588",
    darkblue = "#427b58",
    black = "#3c3836",
    dark_yellow = "#b57614",
    green = "#98971a",
    light_purple = "#8f3f71",
    light_gold = "#ebdbb2",
    gold = "#FFD700"
}

gruvbox["foreground"] = gruvbox["black"]
gruvbox["background"] = gruvbox["light_gold"]

local random = {
    bg = "#202328",
    fg = "#bbc2cf",
    yellow = "#ECBE7B",
    cyan = "#008080",
    darkblue = "#081633",
    green = "#98be65",
    orange = "#FF8800",
    violet = "#a9a1e1",
    magenta = "#c678dd",
    blue = "#51afef",
    red = "#ec5f67"
}

random["foreground"] = random["black"]
random["background"] = random["blue"]

M.random = random
M.gruvbox = gruvbox

return M
