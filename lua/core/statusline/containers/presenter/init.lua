-- configuration
Impl = {}
Impl.UILib = nil

PresenterPort =
    interface.build_interface(
    {
        -- context could have access to both provider and highlights
        -- This is Optional
        {"context", {"table", "table"}},
        {"convert", {"table", "->", "table"}},
        {"draw", {{"table", "string"}, "->", "table"}}
    }
)

Impl.make_view_binder = function(pos)
    return function(drw_stack)
        UI = Impl.UILib
        -- stack -- > ENTITY --> NESTER<Usecases>
        -- --> Converter<controller> --> UI object<presenter>
        -- convert nested object to preseneter_obj
        -- then handler will draw them later on

        local obj = UI.convert(drw_stack)
        UI.draw(obj, pos)

        return drw_stack
    end
end

return {PresenterPort, Impl}
