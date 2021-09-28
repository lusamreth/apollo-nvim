local p, e = loadfile(STATUSLINE_ROOT .. "data-access/port.lua")
PORT = p()
local function mockfn(txt)
    local res = function()
        return txt
    end
    return res
end

local mock = {}
mock = {
    vcs = {
        get_workspace = mockfn("./src"),
        get_branch = mockfn("main-branch"),
        get_commit = mockfn("random commit")
    },
    nvim = {
        get_line_diagnostics = mockfn("11:40"),
        get_line_position = mockfn("11:55"),
        get_page_position = mockfn("78%"),
        getmode = mockfn("normal")
    },
    file = {
        get_filename = mockfn("filename"),
        get_filesize = mockfn("filesize")
    }
}

RES = {}
for name, impl in pairs(mock) do
    assert(impl ~= nil)
    local res = PORT[name].build(impl, true)
    RES[name] = res
end

return RES
