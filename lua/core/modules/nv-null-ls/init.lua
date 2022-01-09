local get_format = access_module('nv-null-ls.formatters')

-- print(vim.inspect(get_format()))
-- make sure to reduce func complexity
-- also install hacking plugin too !
local sources = {
    unpack(get_format()),
}

G = {}
G.override_settings = {}
G.NULL_LOADED = false
G.CACHE_CLIENT = nil

local function init_null_ls(attach_fn)
    local status_ok, null_ls = pcall(require, 'null-ls')
    if not status_ok then
        print('Missing null-ls dependency')
        return
    end

    null_ls.setup({
        debug = true,
        sources = sources,
        -- you can reuse a shared lspconfig on_attach callback here
        on_attach = function(client)
            if client.resolved_capabilities.document_formatting then
                vim.cmd('autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()')
            end
            if attach_fn then
                print('ATTACHING')
                attach_fn(client)
            end
        end,
    })
    G.NULL_LOADED = true
end

local function disable_cap(client, overrides)
    if overrides then
        for _, override in pairs(overrides) do
            client.resolved_capabilities[override] = false
        end
    end
end

-- naming : full or partial(let the server guess its full capability's name)
local function create_override_fn(available_clients)
    function naming_f(key, kind)
        local res
        if kind == 'full' then
            res = key
        else
            if kind == 'partial' then
                res = 'document_' .. key
            else
                error('Unsupported naming option!')
            end
            return res
        end
    end

    return function(exceptions, overlapsed, naming)
        local keep = {}
        for k, v in pairs(exceptions) do
            local name = naming_f(k, naming)
            for i, over in pairs(overlapsed) do
                if over == name and v then
                    table.insert(keep, name)
                    overlapsed[i] = nil
                end
            end
        end

        if keep ~= {} then
            disable_cap(available_clients[exceptions['client']], keep)
        end
    end
end

local function create_override_attachment(lsp_client, priority, exceptions)
    priority = priority or 'lsp'
    override = {}

    -- prioritize lsp but want to preserved formatting and diag for null_ls
    exceptions = exceptions or {
        client = 'null',
        formatting = true,
        diagnostics = true,
    }
    -- priority = priority or 'lsp'
    return function(null_client)
        G.CACHE_CLIENT = null_client
        local lsp_keycaps = vim.tbl_keys(lsp_client.resolved_capabilities)
        local null_keycaps = vim.tbl_keys(null_client.resolved_capabilities)
        local overlapsed = vim.tbl_filter(function(lsp_cap)
            return vim.tbl_contains(null_keycaps, lsp_cap)
        end, lsp_keycaps)

        local clients = {
            null = lsp_client,
            lsp = null_client,
        }
        print('OVERLASPED', vim.inspect(overlapsed))
        create_override_fn(clients)(exceptions, overlapsed, 'partial')
        disable_cap(clients[priority], overlapsed)
    end
end

G.ftcache = {}

---@diagnostic disable-next-line: redefined-local
local function extract_null_ft(sources)
    if not vim.tbl_isempty(G.ftcache) then
        return G.ftcache
    end

    local null_fts = {}
    for _, source in pairs(sources) do
        -- print('SOURCE FT', vim.inspect())
        for _, ft in pairs(source['filetypes']) do
            table.insert(null_fts, ft)
        end
    end
    G.ftcache = null_fts
    return null_fts
end

-- default : prioritize LSP formatting then null_ls
-- custom : could override lsp settings by giving overrides parameters
-- this will only mount null-ls when lsp is online !!
function G.resolve_null_conflict(lsp_client)
    local overide_attachment = create_override_attachment(lsp_client)
    -- require('null-ls').setup({
    --     sources = sources,
    --     on_attach = function(client)
    --         G.cache_client = client
    --         if client.resolved_capabilities.document_formatting then
    --             vim.cmd('autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()')
    --         end
    --         overide_attachment(client)
    --     end,
    -- })

    init_null_ls(overide_attachment)
    if G.CACHE_CLIENT then
        overide_attachment(G.CACHE_CLIENT)
    end
end

G.create_override_attachment = create_override_attachment

return G
