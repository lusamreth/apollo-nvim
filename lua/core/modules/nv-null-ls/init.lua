local get_format = access_module('nv-null-ls.formatters')
local misc = access_module('nv-null-ls.misc')

-- print(vim.inspect(get_format()))
-- make sure to reduce func complexity
-- also install hacking plugin too !
-- local sources = {
--     unpack(get_format()),
--     unpack(misc.diagnostics()),
--     unpack(misc.code_actions()),
-- }
local sources = Utils.table_merge(0, get_format(), misc.diagnostics())
-- print('SOURCEs', vim.inspect(sources))
local G = {}

G.override_settings = {}
G.NULL_LOADED = false
G.CACHE_CLIENT = nil
G.DEBUG = true

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
                -- auto format
                -- print('AUTO _FORMAT !')
                vim.cmd([[
                    augroup LspFormatting
                        autocmd! * <buffer>
                        autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()
                    augroup END
                ]])
            end
            if attach_fn then
                if G.DEBUG then
                    print('ATTACHING')
                end
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
        if G.DEBUG then
            print('OVERLASPED', vim.inspect(overlapsed), lsp_keycaps)
        end

        create_override_fn(clients)(exceptions, overlapsed, 'partial')
        disable_cap(clients[priority], overlapsed)
    end
end

G.ftcache = {}
G.lsp_hook_called = 0

---@diagnostic disable-next-line: redefined-local
function G.extract_null_ft(sources)
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

    G.lsp_hook_called = G.lsp_hook_called + 1

    init_null_ls(overide_attachment)
    if G.CACHE_CLIENT then
        overide_attachment(G.CACHE_CLIENT)
    end
end

G.create_override_attachment = create_override_attachment
G.init_null_ls = init_null_ls

return G
