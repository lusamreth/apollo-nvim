local diagnostic = {}
-- nvim-lspconfig
-- see https://github.com/neovim/nvim-lspconfig
local function get_nvim_lsp_diagnostic(diag_type)
    if next(vim.lsp.buf_get_clients(0)) == nil then
        return ''
    end
    local count = 0

    count = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity[diag_type] })
    -- if diag_type == 'HINT' then
    --     print(diag_type, count)
    -- end
    return count
end

diagnostic.get_diagnostic = function(diag_type)
    local count = 0
    if not vim.tbl_isempty(vim.lsp.buf_get_clients(0)) then
        count = get_nvim_lsp_diagnostic(diag_type)
    end

    return count
end

local function get_formatted_diagnostic(diag_type)
    local count = diagnostic.get_diagnostic(diag_type)
    return count
end

diagnostic.get_diagnostic_error = function()
    return get_formatted_diagnostic('ERROR')
end

diagnostic.get_diagnostic_warn = function()
    return get_formatted_diagnostic('WARN')
end

diagnostic.get_diagnostic_hint = function()
    return get_formatted_diagnostic('HINT')
end

diagnostic.get_diagnostic_info = function()
    return get_formatted_diagnostic('INFO')
end

return diagnostic
