local a = require('plenary.async_lib.tests')
table.unpack = table.unpack or unpack
require('system.inspectors.interface-builder')

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
        end,
    }
    return Impl
end

function BuildMockInterface()
    MockInterface = {
        { 'fn_mock_1', { 'string', '->', 'number' } },
        -- "null_fn",
        {
            'fn_return_only',
            { '->', 'number' },
        },
        { 'fn_input_only', { 'string' } },
    }
    local Mock = interface.build_interface(MockInterface)
    return Mock
end

function Assemble(IMPL)
    print('assembling...')
    local Mock = BuildMockInterface()
    local _, res = pcall(Mock.build, IMPL, true)
    return res
end

-- testing injection
a.describe('interface implementation', function()
    -- abitary build function
    -- mock will take target function and then return
    -- builder function
    local MockFnBuilder = function(targetFn)
        assert(type(targetFn) == 'function', 'this dependency requires function')
        return function()
            return function(...)
                return targetFn(...)
            end
        end
    end

    -- local o = MockFnBuilder(function()
    --     return 1000
    -- end)
    -- print('typeo', type(o))
    local MockBlueprint = {
        build_fn_mock_1 = MockFnBuilder(function(i)
            print('Mock input', i)
            return 100000
        end),
        build_fn_return_only = MockFnBuilder(function()
            return 100000
        end),
        build_fn_input_only = MockFnBuilder(function(i)
            print('Mock input', i)
            print('No return')
        end),
    }

    BUILD_IMPL(MockBlueprint)
    -- inject all builder code
    local res = MockBlueprint.inject({
        build_fn_mock_1 = { 'string', 10000 },
        build_fn_return_only = { nil, 20000 },
        build_fn_input_only = { 'string' },
    })
    a.it('should be injected with no problem', function()
        for n, oi in pairs(res) do
            print('Injected output [' .. n .. '] ==>', assert(type(oi) == 'function'))
        end
    end)

    a.it('should able to build using normal implementation', function()
        local impl1 = BuildMockImpl()

        local Mock = BuildMockInterface()
        local succ, _ = pcall(Mock.build, impl1, true)
        assert.True(succ)
    end)

    a.it('should able to build using blueprint_builder implementation', function()
        local impl = BuildMockImplBlueprint()
        local Mock = BuildMockInterface()
        local succ, _ = pcall(Mock.build, impl, true)
        assert.True(succ)
    end)
end)

local p = interface.build_interface({
    { 'lots_param', { { 'string', 'string', 'string', 'string' }, '->', 'table' } },
})

a.describe('strict interface', function()
    a.it('should not allow wrong name', function()
        succ, _ = pcall(function()
            impl = {}
            impl.wrong_name = function(_) end
            o = p.build(impl, true)
        end)
        assert.True(not succ)
    end)
end)

a.describe('interface', function()
    local impl, module, return_val

    before_each(function()
        impl, return_val, return_val = {}, {}, { passed = true }

        impl.lots_param = function(z, b, c, d)
            print(z, b, c, d)
            return return_val
        end

        module = p.build(impl, true)
    end)

    a.it('checking return func', function()
        -- print(o)
        assert.equal(module.lots_param('a', 'b', 'c', 'd'), return_val)
    end)

    a.it('should not allow wrong param', function()
        local succ, _ = pcall(function()
            x = module.lots_param('a', 0, {}, 'd')
        end)

        assert.True(not succ)
    end)

    a.it('should not allow wrong return ', function()
        local succ, _ = pcall(function()
            return_val = 0
            z = module.lots_param('a', 'cc', 'c', 'd')
        end)
        assert.True(not succ)
    end)
end)

-- test this function the building block of type parser
a.describe('type parser', function()
    local sample, expected, type_checker

    before_each(function()
        type_checker = require('system.inspectors.type_checker')
        expected = { 'string', 'number' }
        sample = {
            -- single input type
            type_checker.parse_type_array({ 'string' }),
            -- 2 input and a return type
            type_checker.parse_type_array({ { 'string', 'number' }, '->', 'table' }),
            -- only return table type
            type_checker.parse_type_array({ '->', 'table' }),
        }
    end)

    a.it('should resolve it impl to string and null', function()
        assert.True(sample[1]['input'] == 'string' and sample[1]['output'] == nil)
    end)

    a.it('should be able to resolve multiple input type', function()
        for i, o in pairs(sample[2]['input']) do
            assert.equal(o, expected[i])
        end
    end)
end)
