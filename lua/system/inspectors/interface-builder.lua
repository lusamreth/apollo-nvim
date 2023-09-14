require('system.inspectors.table')
t = require('system.inspectors.type_checker')
nerror = t.nerror
-- local function nerror(msg, level)
--     print('LEVEL', level)
--     print(debug.traceback('Stack trace'))
--     print(debug.getinfo(1))
--     print('Stack trace end')
--     error(msg, level)
-- end

SCRIPT_ROOT = HOMEROOT .. '/.config/nvim/lua/system/inspectors/'
ENABLE = true

local check_type = t.check_type
local parse_type = t.parse_type
-- setter allow the function to mutate/append data
-- setter also aware of what type this function will use
-- and produce

local define_interface = function(setter, name, fn, types)
    if fn == nil then
        fn = function()
            nerror('This fn name [' .. name .. '] is not yet implemented!', 2)
        end
    end

    local f = check_type(name, fn, types)
    setter(name, f)
end

local function set_error_service(mod)
    setmetatable(mod, {
        __index = function(_, key)
            if table[key] == nil then
                nerror('This property [' .. key .. '] is not registered in this interface', 2)
            else
                return table[key]
            end
        end,
    })
end

-- some logical problem lays round here !
-- please fix it
local make_build_in_bulk = function(setter, interface_definition, interface)
    return function(implementation, strict)
        -- interface example :
        -- name / input / output types are string
        -- if the input / output types is more than one , must
        -- store it in table else, it will throw error
        -- the table must contain just 3 items
        -- {{"fn_name",{ output = {types},input = {types} } }}
        -- or : {{"fn_name",{ {"inputtypes"},"->",{"Outputtypes"} }}}

        strict = strict or false
        assert(type(interface == 'table'), 'interfaces must be table!')
        assert(type(implementation == 'table'), 'implementation must be table!')
        assert(type(strict) == 'boolean', 'strict option only accept boolean')

        for _, ifc in pairs(interface) do
            local name, types
            -- here should check ifc is single string

            -- assume it has no input output
            name = ifc[1]
            if type(ifc) == 'string' then
                name = ifc
            end
            types = parse_type(ifc[2])
            local u = implementation[name]
            if u == nil and strict then
                --error("Interface missing implementation !", 2)
                print('name ==>', name)
                print('ifc', name, types)
                nerror('Interface with this function name: [' .. name .. '] is not found', 2)
            end

            interface_definition(setter, name, u, types)
        end
    end
end

-- interface could be disable to reduce runtime overhead after
-- finishing project / deploy code
-- interface clas
function Unimplemented(set, interfaces_name, types)
    define_interface(set, interfaces_name, nil, types)
end

IC = {}
local function build_interface(interface)
    local M = {}
    local set = function(name, v)
        M[name] = v
    end

    assert(interface ~= nil, 'Cannot accept empty interface!')
    M.interface = interface
    table.freeze(interface)

    -- could define individual interface
    -- or build in bulk
    for _, ifc in pairs(interface) do
        local name = ifc[1]
        -- string(just the name of iterface) mean no output or input
        if type(ifc) == 'string' then
            name = ifc
        end
        -- all declared function are unimplemented
        Unimplemented(set, name, parse_type(ifc[2]))

        -- we later could define the function
    end

    set_error_service(M)
    M['build'] = function(impl, strict)
        -- This will internally mutate interface

        -- if not ENABLE then
        --     return M
        -- end
        make_build_in_bulk(set, define_interface, interface)(impl, strict)
        -- return mutated interface
        return M
    end
    return M
end

-- examples :
-- cont_impl =
-- impl.inject({
--  {"build_padding",{padding,UI}, (args could be single length or array)},
--  {"build_line_position",{line_pos,UI}},
--  {"build_bullet_shape_drawer",{...}}
-- })
-- usable_controller = ctl_interface.build(implementations:cont_impl,strict:true)

-- blueprint contains function that has name with prefix "[make or build]_[interface]"
-- then dependencies will get injected -> real interface implementation

--
function BUILD_IMPL(implementations_blueprint)
    implementations_blueprint['inject'] = function(dependencies)
        local injected = {}
        --i = 0
        --for name, builder in pairs(implementations_blueprint) do
        for bp_ptr, dep in pairs(dependencies) do
            local builder = implementations_blueprint[bp_ptr]
            if type(builder) == 'nil' then
                nerror('reference wrong builder! This builder name [' .. bp_ptr .. '] does not exist', 1)
            end

            if type(builder) ~= 'function' then
                print("builder's type", type(builder))
                nerror('Builder need to be a function!', 1)
            end

            -- dependency could be table or not
            local res
            if type(dep) == 'table' then
                res = builder(table.unpack(dep))
            else
                res = builder(dep)
            end
            -- if #dep > 1 then
            -- else
            -- end

            local slice_name = function(prefixes, s)
                for _, prefix in pairs(prefixes) do
                    if s:sub(1, #prefix) == prefix then
                        return s:sub(#prefix + 1, #s)
                    end
                end
            end

            local fnname = slice_name({ 'make_', 'build_' }, bp_ptr)
            injected[fnname] = res
        end

        return injected
    end
end

IC.build_interface = build_interface
_G.interface = IC
_G.BUILD_IMPL = BUILD_IMPL
