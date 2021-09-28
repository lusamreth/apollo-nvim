M = {}
function M.init(transformer)
    local o = {}

    o.obj = {}

    o.fn = nil

    o.context = function(UiObj)
        o.fn = transformer
        local fetch_data = function()
            return o.data
        end
        local succ, res = pcall(o.fn, fetch_data, UiObj)

        if not succ then
            res = res or ""
            error("error during transforming UiObj!\n" .. res)
        end
        return res
    end

    o.receive = function(data)
        o.data = data
    end
    return o
end

return M
