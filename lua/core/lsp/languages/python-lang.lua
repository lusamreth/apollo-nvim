local lspconfig = require('lspconfig')
local configs = require('lspconfig/configs')
local util = require('lspconfig/util')

local path = util.path

local function get_python_path(workspace)
    -- Use activated virtualenv.
    if vim.env.VIRTUAL_ENV then
        return path.join(vim.env.VIRTUAL_ENV, 'bin', 'python')
    end

    -- Find and use virtualenv in workspace directory.
    for _, pattern in ipairs({ '*', '.*' }) do
        print('WORKSPACEEE', workspace)
        local match = vim.fn.glob(path.join(workspace, 'poetry.lock'))
        if match ~= '' then
            local venv = vim.fn.trim(vim.fn.system('poetry env info -p'))
            return path.join(venv, 'bin', 'python')
        end
    end

    -- Fallback to system Python.
    return vim.fn.exepath('python3') or vim.fn.exepath('python') or 'python'
end

return {
    get_python_path = get_python_path,
}
