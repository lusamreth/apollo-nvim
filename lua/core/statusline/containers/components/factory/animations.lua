-- can change background or foreground
local function chcol(hl, ranges, kind)
    assert(kind == "bg" or kind == "fg", "CAN ONLY CHANGE background or foreground")
    local i = 1
    local timer = vim.loop.new_timer()
    timer:start(
        0, -- wait
        100, -- repeat
        vim.schedule_wrap(
            function()
                if i > #ranges then
                    i = 1
                end
                hl[kind] = ranges[i]
                i = i + 1
            end
        )
    )
end
local holo_color = {
    "#9eadb6",
    "#bd899e",
    "#b9a4d0",
    "#dbbfc9",
    "#cfcfcf"
}

M = {}
function M.init(ui_lib, color)
    M.create_hl_range = function(ranges, kind)
        kind = kind or "bg"
        ranges = ranges or {"light_purple", "red", "green", "darkblue"}

        local hl = {
            fg = "white"
        }

        if color then
            hl = {
                fg = color[hl["fg"]],
                bg = color[hl["bg"]]
            }
        end

        local fn = function(_, _)
            chcol(hl, holo_color, kind)
            return function()
                return {
                    fg = hl["fg"],
                    bg = hl["bg"]
                }
            end
        end

        return ui_lib.create_dynamic_hl(fn)
    end
    --
    --
    M.holo_fade = function(kind)
        return M.create_hl_range(holo_color, kind)
    end
    return M
end

return M
