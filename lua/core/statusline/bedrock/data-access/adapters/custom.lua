-- custom data-access api goes here
-- Currently nothing here yet
-- but this is good for extension
--

-- got from lualine
-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.
local Mode = {}
-- LuaFormatter off
local root_map = {
    Normal = {
        ["n"] = "NORMAL",
        -- ["n"] = "速い",
        ["niI"] = "NORMAL",
        ["niR"] = "NORMAL",
        ["niV"] = "NORMAL",
        --

        ["Rv"] = "V-REPLACE",
        ["Rx"] = "REPLACE",
        --
        ["rm"] = "MORE",
        ["r?"] = "CONFIRM",
        ["!"] = "SHELL"
    },
    Visual = {
        ["no"] = "O-PENDING",
        ["nov"] = "O-PENDING",
        ["noV"] = "O-PENDING",
        ["no"] = "O-PENDING",
        --
        ["v"] = "VISUAL",
        ["V"] = "V-LINE",
        [""] = "V-BLOCK",
        --
        ["s"] = "SELECT",
        ["S"] = "S-LINE",
        [""] = "S-BLOCK"
    },
    Insert = {
        ["i"] = "INSERT",
        ["ic"] = "INSERT",
        ["ix"] = "INSERT"
    },
    Replace = {
        ["R"] = "REPLACE",
        ["Rc"] = "REPLACE",
        ["r"] = "REPLACE"
    },
    Command = {
        ["c"] = "COMMAND",
        ["cv"] = "EX",
        ["ce"] = "EX",
        ["t"] = "TERMINAL"
    }
}

local function flatten(map)
    local res = {}
    for group, e in pairs(map) do
        for o, inner in pairs(e) do
            res[o] = {inner, group}
            --res[o] = inner
        end
    end
    return res
end

local function request_mode(m)
    for group, e in pairs(root_map) do
        for _, inner in pairs(e) do
            if m == inner then
                return group
            end
        end
    end
end

Mode.map = flatten(root_map)
-- LuaFormatter on
local function get_mode()
    local mode_code = vim.api.nvim_get_mode().mode
    if Mode.map[mode_code] == nil then
        return mode_code
    end
    return Mode.map[mode_code][1]
end

M = {}
M.get_mode = get_mode
M.request_mode_group = request_mode

return M
