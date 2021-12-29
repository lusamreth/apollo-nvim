local function calculate_fit(text_obj)
    local full_length = text_obj["property"]["whole_length"]
    local lines = text_obj["lines"]

    return {
        width = math.ceil(full_length + 1),
        height = #lines
    }
end

local function mergetb(t1, t2)
    for k, v in pairs(t2) do
        if type(v) == "table" then
            t1[k] = mergetb(t1[k], t2[k])
        else
            t1[k] = v
        end
    end

    return t1
end

local function create_default(text_obj, pos)
    local full_length = text_obj["property"]["whole_length"]
    if type(pos) == "string" then
        pos =
            create_pos(
            pos,
            {
                height = #text_obj["lines"],
                width = full_length
            }
        )
    else
        pos = {
            col = 0,
            row = 0
        }
    end

    return function(config)
        config = config or {}
        local defaults = {
            border = config["outer_border"] or false,
            col = pos.col,
            row = pos.row,
            anchor = "NW",
            style = "minimal"
        }

        return mergetb(defaults, calculate_fit(text_obj))
    end
end

local pos = function(c, r)
    assert(type(c) == "string" and type(r) == "string")
    return {
        col = c,
        row = r
    }
end

DefinedPos = {}
function create_pos(pos)
end

local function extract_config(text_obj, config)
    if config["winconfig"] == nil then
        local f = create_default(text_obj)
        config["winconfig"] = f()
    else
        local wcfg = config["winconfig"] or nil
        local default = create_default(text_obj, config["pos"])()

        for cfgname, default_cfg in pairs(default) do
            wcfg[cfgname] = wcfg[cfgname] or default_cfg
        end

        local full_length = text_obj["property"]["whole_length"]

        -- position could be predefined
        local pos =
            create_pos(
            config["pos"],
            {
                height = #text_obj["lines"],
                width = full_length
            }
        )

        wcfg["col"] = pos["col"]
        wcfg["row"] = pos["row"]
        print(wcfg["col"], wcfg["row"], pos["col"], pos["row"])
    end
end

local function create_toggler(state_getter, create, destroy)
    return function()
        local open = state_getter()
        -- auto_resize_support()
        if open then
            create()
        else
            destroy()
        end
    end
end

function Statehandler()
    State = false
    return {
        toggle = function()
            return not State
        end
    }
end

return {
    calculate_fit = calculate_fit,
    Statehandler = Statehandler,
    create_toggler = create_toggler
}
