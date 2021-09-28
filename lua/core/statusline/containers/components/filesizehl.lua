M = {}

M.init = function(color, ui_lib)
    M.filesizehl = function(nextbg)
        local shared
        local check_empty = function(hl_empty, pfg)
            return function(fetch_data, ui)
                local initial_hl = ui["hl"]
                shared = shared or fetch_data()

                return function()
                    if type(hl_empty["bg"]) == "function" then
                        hl_empty["bg"] = hl_empty["bg"]()
                    end

                    local ranges = {"blue", "red", "green"}
                    -- local timer = vim.loop.new_timer()
                    -- local i = 1
                    -- timer:start(
                    --     1000, -- wait
                    --     100, -- repeat
                    --     vim.schedule_wrap(
                    --         function()
                    --             if i == 3 then
                    --                 i = 1
                    --             end
                    --             hl_empty["bg"] = ranges[i]
                    --             i = i + 1
                    --         end
                    --     )
                    -- )
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
        local pad =
            ui_lib.create_dynamic_hl(
            check_empty(
                {
                    bg = nextbg,
                    fg = color["red"]
                }
            )
        )

        local empty_size_reac =
            ui_lib.create_dynamic_hl(
            check_empty(
                {
                    bg = color["red"],
                    fg = "white"
                }
            )
        )

        local p =
            ui_lib.create_dynamic_hl(
            check_empty(
                {
                    bg = color["red"]
                },
                true
            )
        )
        return {
            get = function(d)
                shared = d
            end,
            config = {
                padding = pad,
                main = empty_size_reac,
                preserve = p
            }
        }
    end

    return M
end

return M
