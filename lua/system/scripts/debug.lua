local nnoremap = require("utility").keybinds.nnoremap
--auto import
require("utility.keybinds")
require("utility.test")
print("import debug")

local OneTimemetaTable
do
    local protectedTable = {}
    OneTimemetaTable = {
        __index = function(_, k)
            --print("Function access gbinder", t, k)
            local temp = protectedTable[k]
            protectedTable[k] = nil
            return temp
        end,
        __newindex = function(t, k, v)
            protectedTable[k] = v -- update original table
            -- listener(k,v)
        end
    }
end

describe(
    "tsa",
    function()
        print(100)
    end,
    "hmmmm"
)
-- Unit testing starts
TestMetaBd = {
    -- class
    TestInit = function()
        local t = setmetatable(Gbinder, OneTimemetaTable)
        t[1] = "hi"
        local first_access = t[1]
        -- could only access one time
        local second_access = t[1]
        AssertEquals(first_access ~= nil, second_access == nil, true)
    end,
    TestLoop = function()
        local t = setmetatable(Gbinder, OneTimemetaTable)
        local p = "element"
        for i = 1, 100 do
            t[i] = p
        end

        print("AccessTesting")
        for i = 1, 100 do
            local first_access = t[i]
            local second_access = t[i]
            AssertEquals(first_access ~= nil, second_access == nil, false)
        end
        print("Passed No Complain!")
    end
}

-- print(TestMetaBd.method_name())
function hardnesttest()
    describe(
        "te",
        function()
            print("Duh")
            describe(
                "lv1",
                function()
                    describe(
                        "lv2",
                        function()
                            describe(
                                "lv3",
                                function()
                                    describe(
                                        "lv4",
                                        function()
                                        end
                                    ) -- get call first
                                end
                            )
                        end
                    )
                end
            )
        end
    )
end

--[testing mttable]
--describe("Meta table testing",
--    function()
--        for key,testFunc in pairs(TestMetaBd) do
--            describe("Func"..key,testFunc)
--        end
--    end
--)

-- hardnest()
-- TestUtil.store(TestMetaBd)
-- TestUtil.list()
function Profile_plugin()
    print("Activating profiling!\n")
    -- base on :
    -- :profile start profile.log
    -- :profile func *
    -- :profile file *
    -- " At this point do slow actions
    -- :profile pause
    -- :noautocmd qall!
    local leader = "<Space>d"
    local default_profile_folder = "" -- current folder
    local profile_name = vim.fn.input("Profile-Name?")

    local local_bind = function(key, _fd)
        Caller = Gbinder.bind(_fd)
        return nnoremap(key, "lua Caller()")
    end

    local pause_profile_binder = function()
        local _fd = function()
            print("Profiling pause!\nRestart when ready!")
            vim.cmd("profile pause")
        end

        --Caller = Gbinder.bind(_fd)
        --nnoremap(leader .. "w", "lua Caller()")
        local_bind(leader .. "w", _fd)
    end

    local stop_profile_binder = function()
        local _fd = function()
            print("Profiling stop!\nPlease check your result!")
            vim.cmd("profile stop")
        end

        local_bind(leader .. "s", _fd)
    end

    local dumping_profile_binder = function()
        local _fd = function()
            print("Dumping current state to " .. profile_name("!\nPlease check your result!"))
            vim.cmd("profile dump")
        end
        local_bind(leader .. "d", _fd)
    end

    local read_profile = function()
        local _func = function()
            print("Opening vim profile!")
            vim.cmd("tabe" .. profile_name)
        end
        local_bind("ztp", _func)
        --nnoremap("ztp", "lua _func()")
    end

    if profile_name ~= nil then
        vim.cmd("profile start " .. profile_name)
        vim.cmd("profile func *")

        vim.cmd("profile file *")
        print("Testing your neovim behavoir!")

        pause_profile_binder()
        stop_profile_binder()
    else
        print("Invalid profile name! Please set default")
    end
end

require("utility.test")
local utils = require("utility")

function TestTb()
    Describe(
        "tableclonetest",
        function()
            local arr = {1, 2, 3, 5, 6, 7}
            local cloned = utils.table_clone(arr)
            AssertEquals(arr, cloned)
        end
    )

    Describe(
        "tablemergetest",
        function()
            local res = {1, 2, 3, 5, 6, 7}
            local arr1 = {1, 2, 3}
            local arr2 = {4, 5, 6, 7}
            AssertEquals(res, utils.table_merge(arr1, arr2))
        end
    )
end
-- vim.api.nvim_set_keymap("n","nx","<cmd>echo 'help'<CR>",{noremap = true})
nnoremap("nx", "lua Profile_plugin()")
