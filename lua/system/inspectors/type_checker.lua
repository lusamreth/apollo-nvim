require("utility")
T = {}

local function nerror(msg, level)
    print("LEVEL", level)
    print(debug.traceback("Stack trace"))
    print(debug.getinfo(1))
    print("Stack trace end")
    error(msg, level)
end

-- args: must always be table
-- res : must always be table
local function get_each_arg(args)
    local got = {}
    if args == nil then
        nerror("arguments is null!\n Cannot possible be!")
    end

    if #args == 0 then
        return {"NONE"}
    end
    for i, tpa in pairs(args) do
        print("tptpt", tpa)
        got[i] = type(tpa)
    end

    print("arg", args)
    print("gototo", got[1])
    return got
end

local function get_expected(tps)
    -- assert(tps ~= nil, "provided types are nulled")
    local expected
    if type(tps) == "table" then
        expected = unpack(tps)
    else
        expected = tps
    end
    return expected
end

local wrong_type_handle = function(fn_name, args, tps, kind)
    print("This fn name [" .. fn_name .. "] got wrong [[" .. kind .. "]] type")
    print("GOT", unpack(get_each_arg(args)))
    print("EXPECTED", get_expected(tps[kind]))
    -- print("==>", tps["output"])
    nerror("Wrong type according to the interface", 3)
end

local typecheck_iter = function(args, tp)
    if #args == 0 and tp == nil then
        return true
    end

    if type(tp) == "table" then
        for i, arg in pairs(args) do
            return type(arg) == tp[i]
        end
    else
        -- args is always a table
        return type(args[1]) == tp
    end
end

local function parse_type_array(type_arry)
    local res = {
        output = nil,
        input = nil
    }
    local function find_arrow(curr)
        return curr == "->"
    end
    for i, each_type in pairs(type_arry) do
        if find_arrow(each_type) then
            local delim_pos = i
            if delim_pos == 1 then
                res["output"] = type_arry[i + 1]
                break
            else
                res["input"] = type_arry[1]
                res["output"] = type_arry[3]
                break
            end
        else
            res["input"] = type_arry[1]
        end
    end

    -- print("result of parsing", res["input"], "->", res["output"])
    return res
end

-- example : t({{"t1","t2"},"->","return_type"})
local function parse_type(raw_type)
    local res = {
        output = nil,
        input = nil
    }

    if raw_type == nil then
        return res
    end

    if type(raw_type) == "table" then
        -- assert(#raw_type <= 3, "types def must only contains input output and '->'; 3 items")
        -- print("rawww", raw_type)
        return parse_type_array(raw_type)
    end

    -- assume it only has 1 input type
    if type(raw_type) == "string" then
        return {
            input = raw_type,
            output = nil
        }
    end
end

local check_type = function(name, fn, tps)
    local function check_input(input)
        local l = typecheck_iter(input, tps["input"])
        if l == false then
            wrong_type_handle(name, input, tps, "input")
        end
    end

    local function check_output(output)
        local l = typecheck_iter(output, tps["output"])
        if l == false then
            wrong_type_handle(name, output, tps, "output")
        end
    end

    local function typecheck_fn_wrapper(...)
        check_input({...})
        local res = fn(...)
        check_output({res})
        return res
    end
    return typecheck_fn_wrapper
end

-- Testing

-- test this function the building block of type parser
function TestTypeParser()
    local res = {
        -- single input type
        parse_type_array({"string"}),
        -- 2 input and a return type
        parse_type_array({{"string", "number"}, "->", "table"}),
        -- only return table type
        parse_type_array({"->", "table"})
    }

    print(res[1]["input"], res[1]["output"])
    assert(res[1]["input"] == "string" and res[1]["output"] == nil)
    print(res[2]["input"])

    local expected = {"string", "number"}
    for i, o in pairs(res[2]["input"]) do
        assert(o == expected[i])
    end

    assert(res[2]["output"] == "table")
    assert(res[3]["output"] == "table")
    --print(pp["output"], pp["input"])
end
function TestTP2()
    local p = parse_type_array({"string", "->", "string"})
    print(p["input"])
    print(p["output"])
end
T.check_type = check_type
T.parse_type = parse_type
return T
