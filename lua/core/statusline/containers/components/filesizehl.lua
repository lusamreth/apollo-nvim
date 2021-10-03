M = {}

M.init = function(color, ui_lib)
    local shared
    local check_empty = function(hl_empty, pfg)
        return function(fetch_data, ui)
            local initial_hl = ui["hl"]
            shared = shared or fetch_data()

            return function()
                if type(hl_empty["bg"]) == "function" then
                    hl_empty["bg"] = color[hl_empty["bg"]()]
                end

                if pfg then
                    hl_empty = {
                        bg = hl_empty["bg"],
                        fg = initial_hl["fg"]
                    }
                end
                if shared == "NULL" then
                    return hl_empty
                else
                    return initial_hl
                end
            end
        end
    end

    -- preserve is the colors of prior comp,
    M.filesizehl = function(nextbg)
        local secs = {
            padding = {
                bg = nextbg,
                fg = color["red"]
            },
            main = {
                bg = color["red"],
                fg = color["white"]
            },
            preserve = {
                bg = color["red"],
                -- fixme : please specifiy this one
                fg = color["orange"]
            }
        }

        for name, sec in pairs(secs) do
            secs[name] = ui_lib.create_dynamic_hl(check_empty(sec))
        end

        return {
            get = function(d)
                shared = d
            end,
            config = secs
        }
    end

    return M
end

return M
