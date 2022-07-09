local a = require('plenary.async_lib.tests')
require('system.inspectors.table')
require('system.inspectors.interface-builder')

a.describe('test-freezer', function()
    local T
    before_each(function()
        T = {}
        table.freeze(T)
    end)

    a.it("Readonly table can't be changed", function()
        local s, f = pcall(function()
            T[1] = 100
        end)

        assert.equal(s, false)
    end)
end)

function TestFreezer()
    -- test:
    T = {}
    table.freeze(T)

    local s, f = pcall(function()
        T[1] = 100
    end)

    assert(f ~= nil and s == false, "Readonly table can't be changed")
    T = { 1, 2, 3, 5, 6 }
    local spl = table.splice(T, 1, 2)
    printf(spl)
end
