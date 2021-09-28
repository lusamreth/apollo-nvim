Identifier = {}
Nester = {}

function Identifier:init()
    local IdentifierInterface =
        interface.build_interface(
        {
            -- return must not equal to input and unique
            {"get_id", {"string", "->", "string"}},
            -- return key of a nested component
            {"get_key", {"table", "->", "string"}}
        }
    )

    self.interface = IdentifierInterface
    self.get_id = IdentifierInterface.get_id
    self.get_key = IdentifierInterface.get_key
    return self
end

function Identifier:build(impl)
    return self.interface.build(impl, true)
end

-- impl.uniq = Identifier:init(impl)
-- impl.uniq.insert(identifier_impl)

function Nester:init()
    local NesterInterface =
        interface.build_interface(
        {
            {"nest", {{"string", "table"}, "->", "table"}}
        }
    )

    self.interface = NesterInterface
    self.nest = NesterInterface.nest
    return self
end

function Nester:build(impl)
    return self.interface.build(impl)
end

return {
    Identifier = Identifier,
    Nester = Nester
}
