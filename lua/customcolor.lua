-- Taken from zehpyr theme repo
--[[
--group = {
--  [name] = {
--     fg = col[hex]
--     bg = col[hex]
--     style = name[string]
--  }
--}
--]]
-- this won't work unless you turn off colorscheme
local red = "#ea6962"
local orange = "#e78a4e"
local yellow = "#d8a657"
local green = "#a9b665"
local aqua = "#89b482"

local nord = "#81A1C1"
local blue = "#51afef"
local darkblue = "#081633"
local sakura_pink = "#F9E9EC"
local bg = "#262727"
local light_soft = "#f2e5bc"
local custom = {}

function custom.highlight(group, color)
    local style = color.style and "gui=" .. color.style or "gui=NONE"
    local fg = color.fg and "guifg=" .. color.fg or "guifg=NONE"
    local cbg = color.bg and "guibg=" .. color.bg or "guibg=NONE"
    local sp = color.sp and "guisp=" .. color.sp or ""
    vim.api.nvim_command("highlight " .. group .. " " .. style .. " " .. fg .. " " .. cbg .. " " .. sp)
end

local syntax = {
    -- won't work if other statusline is enabled!
    TelescopeBorder = {fg = blue},
    TelescopePromptBorder = {fg = red},
    TelescopeMatching = {fg = aqua},
    TelescopeSelection = {fg = yellow, bg = red, style = "bold"},
    TelescopeSelectionCaret = {fg = yellow},
    TelescopeMultiSelection = {fg = aqua},
    --Pmenu = {
    --    fg=darkblue,
    --    bg=light_soft
    --},
    --PmenuSel = {
    --    fg=sakura_pink,
    --    bg=bg
    --},
    PmenuSelBold = {fg = bg},
    PmenuSbar = {},
    PmenuThumb = {}
}
-- important otherwise galaxyline won't work
vim.o.termguicolors = true
for group, col in pairs(syntax) do
    custom.highlight(group, col)
end

--vim.g[]
