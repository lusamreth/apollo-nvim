function TestFreezer()
    -- test:
    T = {}
    table.freeze(T)

    local s, f =
        pcall(
        function()
            T[1] = 100
        end
    )

    assert(f ~= nil and s == false, "Readonly table can't be changed")
    T = {1, 2, 3, 5, 6}
    local spl = table.splice(T, 1, 2)
    printf(spl)
end
