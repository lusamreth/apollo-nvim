function TestInterface()
    function BuildMockInterface()
        MockInterface = {
            {"fn_mock_1", {"string", "->", "number"}},
            -- "null_fn",
            {
                "fn_return_only",
                {"->", "number"}
            },
            {"fn_input_only", {"string"}}
        }
        local Mock = interface.build_interface(MockInterface)
        return Mock
    end

    function BuildMockImpl()
        Impl = {
            fn_mock_1 = function(_)
                return 100000
            end,
            -- null_fn = function()
            -- end,
            fn_return_only = function()
                return 100000
            end,
            fn_input_only = function(i)
                return i
            end
        }
        return Impl
    end

    function Assemble(IMPL)
        print("assembling...")
        local Mock = BuildMockInterface()
        local success, res = pcall(Mock.build, IMPL, true)
        res = res or "success"
        assert(success == true, "failed test! should spit out correct\nr")
        return res
    end

    function BuildMockImplBlueprint()
        -- abitary build function
        -- mock will take target function and then return
        -- builder function
        local MockFnBuilder = function(targetFn)
            assert(type(targetFn) == "function", "this dependency requires function")
            return function()
                return function(...)
                    return targetFn(...)
                end
            end
        end

        local o =
            MockFnBuilder(
            function()
                return 1000
            end
        )
        print("typeo", type(o))
        MockBlueprint = {
            build_fn_mock_1 = MockFnBuilder(
                function(i)
                    print("Mock input", i)
                    return 100000
                end
            ),
            build_fn_return_only = MockFnBuilder(
                function()
                    return 100000
                end
            ),
            build_fn_input_only = MockFnBuilder(
                function(i)
                    print("Mock input", i)
                    print("No return")
                end
            )
        }

        BUILD_IMPL(MockBlueprint)
        -- inject all builder code
        local res =
            MockBlueprint.inject(
            {
                build_fn_mock_1 = {"string", 10000},
                build_fn_return_only = {nil, 20000},
                build_fn_input_only = {"string"}
            }
        )

        print("building shit")
        for n, oi in pairs(res) do
            print("Injected output [" .. n .. "] ==>", assert(type(oi) == "function"))
        end

        return res
    end

    local impl1 = BuildMockImpl()
    print("Testing Normal implementation...")
    Assemble(impl1).fn_mock_1("bruh")

    print("Testing implementation derived from blueprint_builder! ...")
    local impl2 = BuildMockImplBlueprint()
    Assemble(impl2).fn_mock_1("bruh")
end

function TestType2()
    local p =
        interface.build_interface(
        {
            {"lots_param", {{"string", "string", "string", "string"}, "->", "table"}}
        }
    )
    local impl = {}

    impl.lots_param = function(a, b, c, d)
        print(a, b, c, d)
        return {}
    end

    local o = p.build(impl, true)
    o.lots_param("a", "b", "c", "d")
end
