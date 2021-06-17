local custom_cfg_table = {}
local conf = {}
do
    custom_cfg_table = {
        _index = function(t,k)
            if conf[k] == nil then
                    error("The configuration is not avialable!")
                    error("Please recheck your options!")
                return
                else
                    return conf[k]
            end
        end
    }
end

config = setmetatable({},custom_cfg_table)

function append_local_config(name,cfg)
    _G.config[name] = setmetatable(cfg,custom_cfg_table)
end

function delete_local_config()

end

function buildErrorHandler()
    if TestUtil.options.buffer == false then
        -- return builtin error
        return error
    else
        return buffer_error
    end

end

function bufferError(msg,lvl,verb)
    
end

function AssertEquals(e1, e2,v)
    if type(e1) ~= type(e2) then
        error("Two incompatible type, cannot compare!")
        return
    end

    if v == true then
    else
        local s = function(d,va)
            string.format("value of %s: %s",d,va) 
        end

        s("lhs",e1)
        s("lhs",e1)
    end

    if e1 ~= e2 then
        error("Two variable is not equal!",2)
        error("Assertion Failed!", 2)
    else
        print("Assertion pass!")
    end
end


function TraceCaller()
    print(debug.traceback())
    local current_func = debug.getinfo(1)
    local calling_func = debug.getinfo(2)

    print("Current Func :", current_func.name)
    print("Caller that cur func is nested in : ", calling_func.name)
end


local TestUtil = {}
local Test_subject = {}
-- [[ 
-- semantic
-- describe("modname",
--  function() <-- definition,
--  opts,
-- ,)
-- ]]
local called_time = 0

-- TestUtil.test

function Describe(modname, definition, desc)
    -- increment when call
    called_time = called_time + 1
    local indx = #Test_subject + 1
    local d
    if config.trace == true then 
        TraceCaller()
    end
    if desc == nil then
        d = "Testing modname " .. modname
    else
        d = desc
    end

    local obj = {test = indx, name = modname, sub = definition, desc = d}
    -- calling the insider test

    -- mount onto Test_subject
    Test_subject[indx] = obj
end

function Runtest()
    local START,END
    for key,obj in pairs(Test_subject) do
        print("Running test "..key)
        START = os.clock()
        obj["sub"]()
        END = os.clock()

        obj["runtime"] = END
        print(obj["name"], END)
    end

    print_table()
end

function listtest()
   for key,obj in pairs(Test_subject) do 
       print(string.format("%s.%s",key,obj["name"]))
   end
end

function print_table()
    -- decore!
    local add_dash = function(str, maxLen)
        local num = math.floor((maxLen - #str) / 2)
        local side = string.rep("-", num)
        return side .. str .. side
    end

    local print_dash = function(str, len) print(add_dash(str, len)) end

    -- traverse through object prop
    for i = 1, #Test_subject do
        local get_ele = function(n)
            local s = Test_subject[i][n]
            return "--> " .. n .. " :" .. s
        end
        local content = ""

        local longest_len = 0
        local add_content = function(fields)
            for i = 1, #fields do
                local e = get_ele(fields[i])
                local new_line = "\n"
                local line = content .. e .. new_line
                if #line > longest_len then longest_len = #line end
                content = line
                -- content 
                -- print()
            end
        end

        -- local n,d = get_ele("name"),get_ele("desc")
        local fields = {"name", "desc", "runtime"}
        add_content(fields)
        -- if #n > #d then longest_len = #n else longest_len = #d end
        longest_len = longest_len + 2

        local longest_len = 50
        print_dash("num" .. i, longest_len)
        -- print(n.."\n"..d)
        print(content)
        print_dash("", longest_len)
    end
end

function test (desc, testLogic) 
    
end

function timeout()

end

-- Test module options :
-- buffer : bool,
-- verbose : bool,
-- timeout : time(float | int)
-- runall : bool

return TestUtil

