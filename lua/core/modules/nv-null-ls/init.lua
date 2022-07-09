local get_format = access_module('nv-null-ls.formatters')
local misc = access_module('nv-null-ls.misc')

local sources = Utils.table_merge(0, get_format(), misc.diagnostics())
-- print('SOURCEs', vim.inspect(sources))
local G = {}

G.override_settings = {}
G.NULL_LOADED = true
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
            if client.server_capabilities.documentFormattingProvider then
                print('formatting from null-lsp')
                vim.cmd([[
                    augroup LspFormatting
                        autocmd! * <buffer>
                        autocmd BufWritePre <buffer> lua vim.lsp.buf.format()
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
    vim.pretty_print(overrides)
    if overrides then
        -- vim.pretty_print('before', client.server_capabilities)
        for _, override in pairs(overrides) do
            client.server_capabilities[override] = false
        end
        -- vim.pretty_print('after', client.server_capabilities)
    end
    -- print('CLIENT', vim.inspect(client.server_capabilities))
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
            elseif kind == 'camelCase' then
                res = 'document' .. firstToUpper(key) .. 'Provider'
            else
                error('Unsupported naming option!')
            end

            -- vim.pretty_print(res)
            return res
        end
    end

    -- create an exception preventing full override
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

        -- This logic will disable some feature of LSP capabilities in order for
        -- null ls to replace those capabilities instead; ie formatting_document
        if keep ~= {} then
            client_key = vim.tbl_keys(available_clients)
            intact_feature = vim.tbl_filter(function(key)
                return key ~= exceptions['client']
            end, client_key)

            vim.pretty_print(string.format('DISABLING %s client to keep %s features intact', exceptions['client'], vim.inspect(intact_feature)))
            disable_cap(available_clients[exceptions['client']], keep)
        end
    end
end

local function create_override_attachment(lsp_client, priority, exceptions)
    priority = priority or 'lsp'
    override = {}

    -- lsp_client.server_capabilities.document_formatting = false

    -- prioritize lsp but want to preserved formatting and diag for null_ls
    exceptions = exceptions or {
        client = 'lsp',
        formatting = true,
    }

    return function(null_client)
        G.CACHE_CLIENT = null_client
        local lsp_keycaps = vim.tbl_keys(lsp_client.server_capabilities)
        local null_keycaps = vim.tbl_keys(null_client.server_capabilities)
        -- vim.pretty_print("nulla",null_client.server_capabilities)
        -- vim.pretty_print("LSP",lsp_client.server_capabilities)

        local overlapsed = vim.tbl_filter(function(lsp_cap)
            return vim.tbl_contains(null_keycaps, lsp_cap)
        end, lsp_keycaps)

        -- this client is for override fn to select
        -- if client choose null ,then null-ls is excepted and won't disable
        -- any overlapsed capabilities
        local clients = {
            null = lsp_client,
            lsp = null_client,
        }

        if G.DEBUG then
            print('OVERLASPED', vim.inspect(overlapsed), lsp_keycaps)
        end

        -- overfn take care of destroying
        --
        create_override_fn(clients)(exceptions, overlapsed, 'camelCase')
        -- disable_cap(clients[priority], overlapsed)
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
--
function G.resolve_null_conflict(lsp_client)
    local overide_attachment = create_override_attachment(lsp_client, 'lsp')
    print('RESOLVING CONFLICTED!!')
    G.lsp_hook_called = G.lsp_hook_called + 1

    init_null_ls(overide_attachment)
    if G.CACHE_CLIENT then
        overide_attachment(G.CACHE_CLIENT)
    end
end

G.create_override_attachment = create_override_attachment
G.init_null_ls = init_null_ls

return G
