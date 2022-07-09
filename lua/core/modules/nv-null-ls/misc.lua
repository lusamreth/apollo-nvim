local h = access_module('nv-null-ls.helpers')
local diagnostics = {
    'flake8',
    'eslint_d',
    'luacheck',
    'yamllint',
}

function mock_handle()
    local m = {}
    m.handle = function(_) end
    m.build = function(_) end
    return m
end

local code_actions = {}

return {
    diagnostics = h.BuiltinFactory(diagnostics, 'diagnostics', mock_handle),
    code_actions = h.BuiltinFactory(code_actions, 'code_actions', mock_handle),
}
