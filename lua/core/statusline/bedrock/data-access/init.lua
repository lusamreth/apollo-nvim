local port, _ = loadfile(BEDROCK_ROOT .. "data-access/port.lua")
local g, _ = loadfile(BEDROCK_ROOT .. "data-access/adapters/galaxyline.lua")
-- local g, _ = loadfile(STATUSLINE_ROOT .. "data-access/mock.lua")
-- local g, _ = loadfile(STATUSLINE_ROOT .. "data-access/adapters/feline.lua")
-- local o, _ = loadfile(STATUSLINE_ROOT .. "data-access/adapters/gls-custom.lua")
local gls_impl = g()
PORT = port()

RES = {}
for name, impl in pairs(gls_impl) do
    assert(impl ~= nil)
    local res = PORT[name].build(impl, false)
    RES[name] = res
end

return RES
