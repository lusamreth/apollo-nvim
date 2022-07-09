-- can change background or foreground
local function chcol(hl, ranges, kind)
    assert(kind == 'bg' or kind == 'fg', 'CAN ONLY CHANGE background or foreground')
    local i = 1
    local timer = vim.loop.new_timer()
    timer:start(
        0, -- wait
        120, -- repeat
        vim.schedule_wrap(function()
            if i > #ranges then
                i = 1
            end
            hl[kind] = ranges[i]
            i = i + 1
        end)
    )
end
local holo_color = {
    '#9eadb6',
    '#bd899e',
    --
    '#004444',
    '#b9a4d0',
    '#691aff',
    --
    '#340d7f',
    '#dbbfc9',
    '#008080',
    '#3366cc',
    -- "#cfcfcf"
}

local gold_shades = {
    '#f5d000',
    '#e0bf00',
    '#ccad00',
    '#b89c00',
    '#f0cc00',
    '#dbba00',
    '#c7a900',
    '#b39800',
    '#e6c300',
    '#d1b200',
    '#bda000',
    '#a88f00',
}

local function get_opposite(kind)
    local opposite
    if kind == 'bg' then
        opposite = 'fg'
    else
        opposite = 'bg'
    end
    return opposite
end

M = {}
function M.init(ui_lib, color)
    -- function(bgranges,fgranges)
    M.create_hl_range = function(ranges, kind, opposite_kind)
        kind = kind or 'bg'
        ranges = ranges or { 'light_purple', 'red', 'green', 'darkblue' }

        if kind and opposite_kind == nil then
            error('if kind is' .. kind .. 'need to supply the contrast color too!')
        end

        local hl = {
            [get_opposite(kind)] = opposite_kind or 'white',
        }

        if color then
            hl = {
                fg = color[hl['fg']],
                bg = color[hl['bg']],
            }
        end

        local fn = function(_, _)
            chcol(hl, ranges, kind)
            chcol(hl, ranges, 'fg')

            return function()
                return {
                    fg = hl['fg'],
                    bg = hl['bg'],
                }
            end
        end

        return ui_lib.create_dynamic_hl(fn)
    end

    M.create_hl_range = function(ranges, kind, opposite_kind)
        kind = kind or 'bg'
        ranges = ranges or { 'light_purple', 'red', 'green', 'darkblue' }

        if kind and opposite_kind == nil then
            error('if kind is' .. kind .. 'need to supply the contrast color too!')
        end

        local hl = {
            [get_opposite(kind)] = opposite_kind or 'white',
        }

        if color then
            hl = {
                fg = color[hl['fg']],
                bg = color[hl['bg']],
            }
        end

        local fn = function(_, _)
            chcol(hl, ranges, kind)
            return function()
                return {
                    fg = hl['fg'],
                    bg = hl['bg'],
                }
            end
        end

        return ui_lib.create_dynamic_hl(fn)
    end
    --
    -- h2 : alternative color , for example if kind
    -- is bg then h2 will be fg
    M.holo_fade = function(kind, h2)
        return M.create_hl_range(holo_color, kind, h2)
    end

    M.gold_shade = function(kind, h2)
        return M.create_hl_range(holo_color, kind, h2)
    end

    return M
end

return M
