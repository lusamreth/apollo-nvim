local get_format = access_module('nv-null-ls.formatters')
local misc = access_module('nv-null-ls.misc')

local sources = Utils.table_merge(0, get_format(), misc.diagnostics())

local G = {}

G.override_settings = {}
G.NULL_LOADED = false
G.CACHE_CLIENT = nil
G.DEBUG = false

local lsp_formatting = function(bufnr)
    vim.lsp.buf.format({
        filter = function(client)
            return client.name == 'null-ls'
        end,
        bufnr = bufnr,
    })
end

-- if you want to set up formatting on save, you can use this as a callback
local augroup = vim.api.nvim_create_augroup('LspFormatting', {})

local function init_null_ls(attach_fn)
    local status_ok, null_ls = pcall(require, 'null-ls')
    if not status_ok then
        print('Missing null-ls dependency')
        return
    end

    null_ls.setup({
        debug = true,
        sources = sources,
        -- on_attach = on_attach,
        -- you can reuse a shared lspconfig on_attach callback here
        on_attach = function(client, bufnr)
            G.CACHE_CLIENT = client

            if client.supports_method('textDocument/formatting') then
                vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
                vim.api.nvim_create_autocmd('BufWritePre', {
                    group = augroup,
                    buffer = bufnr,
                    callback = function()
                        -- on 0.8, you should use vim.lsp.buf.format({ bufnr = bufnr }) instead
                        -- vim.lsp.buf.formatting_sync()
                        vim.lsp.buf.format({ bufnr = bufnr })
                    end,
                })
            end
            if attach_fn then
                if G.DEBUG then
                    print('ATTACHING')
                end

                attach_fn(client)
                G.NULL_LOADED = true
                G.CACHE_CLIENT = client
            end
        end,
    })
end

local function disable_cap(client, overrides)
    if overrides then
        for _, override in pairs(overrides) do
            client.server_capabilities[override] = false
            client.server_capabilities['documentRangeFormattingProvider'] = false
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
            elseif kind == 'camelCase' then
                res = 'document' .. firstToUpper(key) .. 'Provider'
                print('res res res', res)
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

            vim.print(string.format('DISABLING %s client to keep %s features intact', exceptions['client'], vim.inspect(intact_feature)))
            disable_cap(available_clients[exceptions['client']], keep)
        end
    end
end

local function create_override_attachment(lsp_client, priority, exceptions)
    priority = priority or 'lsp'
    override = {}
    -- lsp_client.server_capabilities.document_formatting = false
    -- prioritize lsp but want to preserved formatting and diag for null_ls
    --
    exceptions = exceptions or {
        client = 'null',
        formatting = true,
    }

    return function(null_client)
        G.CACHE_CLIENT = null_client

        local lsp_keycaps = vim.tbl_keys(lsp_client.server_capabilities)
        local null_keycaps = vim.tbl_keys(null_client.server_capabilities)

        local overlapsed = vim.tbl_filter(function(lsp_cap)
            return vim.tbl_contains(null_keycaps, lsp_cap)
        end, lsp_keycaps)

        local oppo_clients = { null = lsp_client, lsp = null_client }

        if G.DEBUG then
            print('OVERLASPED', vim.inspect(overlapsed), lsp_keycaps)
        end

        -- overfn take care of destroying
        create_override_fn(oppo_clients)(exceptions, overlapsed, 'camelCase')
        -- disable_cap(clients[priority], overlapsed)
    end
end

G.ftcache = {}
G.lsp_hook_called = 0

---@diagnostic disable-next-line: redefined-local
function G.extract_null_ft(b_source)
    if not vim.tbl_isempty(G.ftcache) then
        return G.ftcache
    end

    local null_fts = {}
    for _, source in pairs(b_source) do
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

-- this function fetch the client from lsp server before initing null_ls
function G.resolve_null_conflict(lsp_client)
    local overide_attachment = create_override_attachment(lsp_client, 'lsp')

    if G.lsp_hook_called == 0 then
        init_null_ls(overide_attachment)
    end
    G.lsp_hook_called = G.lsp_hook_called + 1
end

G.create_override_attachment = create_override_attachment
G.init_null_ls = init_null_ls

-- require('mason-null-ls').setup({
--     ensure_installed = {
--         -- Opt to list sources here, when available in mason.
--     },
--     automatic_installation = false,
--     automatic_setup = true, -- Recommended, but optional
-- })

-- local status_ok, null_ls = pcall(require, 'null-ls')

-- null_ls.setup({
--     debug = true,
--     sources = sources,
--     on_attach = function(client, bufnr)
--         G.CACHE_CLIENT = client

--         if client.supports_method('textDocument/formatting') then
--             vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
--             vim.api.nvim_create_autocmd('BufWritePre', {
--                 group = augroup,
--                 buffer = bufnr,
--                 callback = function()
--                     -- on 0.8, you should use vim.lsp.buf.format({ bufnr = bufnr }) instead
--                     -- vim.lsp.buf.formatting_sync()
--                     lsp_formatting(bufnr)
--                 end,
--             })
--         end
--     end,
-- })

-- require('mason-null-ls').setup_handlers() -- If `automatic_setup` is true.
return G
