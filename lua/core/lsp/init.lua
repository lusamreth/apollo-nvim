-- Global var wtih dtpath
DATA_PATH = vim.fn.stdpath('data')
LSP_REPO = DATA_PATH .. '/lspinstall/'

local null = access_module('nv-null-ls.init')

local lspImport = make_import(LUAROOT .. '/core/lsp/')
-- define the sign !
local function diagnostic_definition(signs)
    if signs == nil then
        signs = {
            error_sign = '',
            warn = ' ',
            hint = '',
            info = '',
        }
    end
    vim.fn.sign_define('DiagnosticSignError', { texthl = 'DiagnosticSignError', text = signs.error_sign, numhl = 'DiagnosticSignError' })
    vim.fn.sign_define('DiagnosticSignWarn', { texthl = 'DiagnosticSignWarn', text = signs.warn, numhl = 'DiagnosticSignWarn' })
    vim.fn.sign_define('DiagnosticSignHint', { texthl = 'DiagnosticSignHint', text = signs.hint, numhl = 'DiagnosticSignHint' })
    vim.fn.sign_define('DiagnosticSignInfo', { texthl = 'DiagnosticSignInfo', text = signs.info, numhl = 'DiagnosticSignInfo' })
    --print(vim.fn.bufname("%"))
end

local function LspSagaExtension(bufnr, prefix)
    local map = function(...)
        return vim.api.nvim_buf_set_keymap(...)
    end

    map(bufnr, 'n', prefix .. 'rn', '<cmd>Lspsaga rename<cr>', { silent = true, noremap = true })
    map(bufnr, 'n', prefix .. 'x', '<cmd>Lspsaga code_action<cr>', { silent = true, noremap = true })
    map(bufnr, 'x', prefix .. 'x', ':<c-u>Lspsaga range_code_action<cr>', { silent = true, noremap = true })
    map(bufnr, 'n', prefix .. 'o', '<cmd>Lspsaga show_line_diagnostics<cr>', { silent = true, noremap = true })
    map(bufnr, 'n', prefix .. 'dn', '<cmd>Lspsaga diagnostic_jump_next<cr>', { silent = true, noremap = true })
    map(bufnr, 'n', prefix .. 'dp', '<cmd>Lspsaga diagnostic_jump_prev<cr>', { silent = true, noremap = true })

    map(bufnr, 'n', 'K', '<cmd>Lspsaga hover_doc<cr>', { silent = true, noremap = true })

    map(bufnr, 'n', '<C-u>', "<cmd>lua require('lspsaga.action').smart_scroll_with_saga(-1)<cr>", {})
    map(bufnr, 'n', '<C-d>', "<cmd>lua require('lspsaga.action').smart_scroll_with_saga(1)<cr>", {})
end

-- force native omnifunc to use lsp.omnifunc
-- vim.api.nvim_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")
-- Mappings.
local opts = { noremap = true, silent = true }

-- todo : integrate lspsaga into lsp
local function build_mapper(leaders)
    local default = { 'g', '<space>', 'd' }
    if leaders == nil then
        leaders = {
            leader1 = default[1],
            leader2 = default[2],
            leader3 = default[3],
        }
    end

    local l1 = leaders.leader1
    local l2 = leaders.leader2
    local l3 = leaders.leader3

    return function(client, bufnr)
        --helpers setting local keymap
        local function buf_set_keymap(...)
            vim.api.nvim_buf_set_keymap(bufnr, ...)
        end

        local function buf_set_option(...)
            vim.api.nvim_buf_set_option(bufnr, ...)
        end

        -- enable format on save

        buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')
        -- g prefixes
        --Nnoremap("fs")
        buf_set_keymap('n', l1 .. 'D', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
        buf_set_keymap('n', l1 .. 'd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)

        buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
        buf_set_keymap('n', l1 .. 'i', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
        buf_set_keymap('n', l1 .. 'r', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
        -- special binder
        buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
        buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
        -- leaders grouping
        -- leader 2 relating to workspace
        buf_set_keymap('n', l2 .. 'wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
        buf_set_keymap('n', l2 .. 'wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
        buf_set_keymap('n', l2 .. 'wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
        buf_set_keymap('n', l2 .. 'D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)

        -- good for bugfixing :
        buf_set_keymap('n', l2 .. 'e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
        -- list errors / hints in quickfix list!
        buf_set_keymap('n', l2 .. 'q', '<cmd>lua vim.diagnostic.set_loclist({ severity_limit = "Warning","Error"  })<CR>', opts)
        -- rename functions or variables in the current buffer
        buf_set_keymap('n', l2 .. 'rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
        -- go to the next diagnostic / error code block
        buf_set_keymap('n', l2 .. 'dn', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
        buf_set_keymap('n', l2 .. 'dp', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)

        -- check if server could format the document
        if client.server_capabilities.document_highlight then
            buf_set_keymap('n', l2 .. 'f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
        elseif client.server_capabilities.document_range_formatting then
            buf_set_keymap('n', l2 .. 'f', '<cmd>lua vim.lsp.buf.range_formatting()<CR>', opts)
        end

        -- leader 3
        buf_set_keymap('n', '[' .. l3, '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
        buf_set_keymap('n', ']' .. l3, '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)

        -- override the default
        LspSagaExtension(bufnr, l2)
        -- lua require('lspsaga.rename').rename()
    end
end

--vim.api.nvim_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
--auto formatting when server is loaded
local function documentHighlight(client)
    -- Set autocommands conditional on server_capabilities
    if client.server_capabilities.document_highlight then
        vim.api.nvim_exec(
            [[
          hi LspReferenceRead cterm=bold ctermbg=red guibg=#fff
          hi LspReferenceText cterm=bold ctermbg=red guibg=#fff
          hi LspReferenceWrite cterm=bold ctermbg=red guibg=#464646
          augroup lsp_document_highlight
            autocmd! * <buffer>
            autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
            autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
          augroup END
        ]],
            false
        )
    end
end

-- textDocument/codeAction.
-- textDocument/completion.
-- textDocument/documentHighlight.
-- textDocument/documentLink.
-- textDocument/documentSymbol.
-- textDocument/foldingRanges.
-- textDocument/formatting.
-- textDocument/hover.
-- textDocument/rangeFormatting
-- textDocument/rename.

local doc_capabilities = {
    documentationFormat = { 'markdown', 'plaintext' },
    -- for luasnip to work
    snippetSupport = true,
    -- preselect autocomplete
    preselectSupport = true,
    insertReplaceSupport = true,
    labelDetailsSupport = true,
    deprecatedSupport = true,
    commitCharactersSupport = true,
    -- diagnostics
    publishDiagnostics = vim.lsp.with(vim.diagnostic.on_publish_diagnostics, {
        virtual_text = true,
        underline = true,
        signs = true,
        update_in_insert = false,
    }),
    tagSupport = { valueSet = { 1 } },
    resolveSupport = {
        properties = {
            'documentation',
            'detail',
            'additionalTextEdits',
        },
    },
}

local function common_capabilities(client)
    local capabilities = vim.lsp.protocol.make_client_capabilities()

    local function set_config(name, config)
        local set_completion_item = function(key, v)
            capabilities[name].completion.completionItem[key] = v
        end

        for k, v in pairs(config) do
            set_completion_item(k, v)
        end
    end

    local function advertise_cmp()
        client.capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)
    end

    advertise_cmp()
    set_config('textDocument', doc_capabilities)
    documentHighlight(client)
end

local lsp_config = {}

local show_func_sig = function()
    local sig_cfg = {
        bind = true, -- This is mandatory, otherwise border config won't get registered.
        -- If you want to hook lspsaga or other signature handler, pls set to false
        doc_lines = 0, -- only show one line of comment set to 0 if you do not want API comments be shown
        hint_enable = true, -- virtual hint enable
        hint_prefix = '󰿉 ',
        hint_scheme = 'String',
        use_lspsaga = false, -- set to true if you want to use lspsaga popup
        handler_opts = {
            border = 'single', -- double, single, shadow, none
        },
        decorator = { '`', '`' }, -- or decorator = {"***", "***"}  decorator = {"**", "**"} see markdown help
    }
    require('lsp_signature').on_attach(sig_cfg)
end

lspImport('diag-border')
local function mount_tools()
    require('lsp-colors').setup({
        Error = '#db4b4b',
        Warning = '#e0af68',
        Information = '#0db9d7',
        Hint = '#10B981',
    })
    local modules = {
        'nv-cmp',
        'nv-lightbulb',
        'nv-trouble',
        'nv-iron',
    }

    for _, mod in pairs(modules) do
        access_module(mod)
    end
    -- show function signature when typing
    MakeTrouble('<Space>')
    show_func_sig()
end

local opt = require('system.scripts.meta-data')

local lsp_formatting = function(bufnr)
    vim.lsp.buf.format({
        filter = function(client)
            -- apply whatever logic you want (in this example, we'll only use null-ls)
            return client.name == 'null-ls'
        end,
        bufnr = bufnr,
    })
end

-- if you want to set up formatting on save, you can use this as a callback
local augroup = vim.api.nvim_create_augroup('LspFormatting', {})

-- add to your shared on_attach callback
local reset_format = function(client, bufnr)
    if client.supports_method('textDocument/formatting') then
        vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
        vim.api.nvim_create_autocmd('BufWritePre', {
            group = augroup,
            buffer = bufnr,
            callback = function()
                lsp_formatting(bufnr)
            end,
        })
    end
end
-- require('lspconfig').html.setup({})
-- t:table -> { client,bufnr,conf }
local function attach_builder(t)
    local conf = t.config
    if t.mapper_builder == nil then -- non_null value
        --default options
        lsp_config.mapper = build_mapper(conf.leaders)
    else
        lsp_config.mapper = t.mapper_builder(conf.leaders)
    end

    -- the args is necessary
    local on_attach = function(client, bufnr)
        -- useful additions such as diagnostics panel, auto-
        -- complete, formatter, ...
        if t.on_mount then
            print('calling on mount!')
            t.on_mount(client, bufnr)
        end
        mount_tools()
        -- important func!
        -- capabilities setting
        common_capabilities(client)
        -- provide diag signs
        diagnostic_definition(t.diagnostic_signs)
        -- setting keymaps and shortcuts
        -- client.server_capabilities.documentFormattingProvider = false
        -- client.server_capabilities.documentRangeFormattingProvider = false

        -- reset_format(client, bufnr)

        null.resolve_null_conflict(client)
        -- vim.pretty_print('cappppa', client.server_capabilities.documentFormattingProvider)
        lsp_config.mapper(client, bufnr)
        print('resolving')
    end

    return on_attach
end

local function on_common_attach(verb, on_mount)
    if verb then
        print('debugging on!')
        print(debug.getinfo(1))
    end

    -- disable coc avoid conflicting with lsp
    local v_t = {
        on_mount = on_mount,
        config = {
            leaders = nil,
            -- use default signs!
            diagnostic_signs = nil,
        },
        snippet = true,
    }
    return attach_builder(v_t) -- <-- func!
end

local lsp_module = {}
lsp_module.build_attacher = attach_builder
lsp_module.on_common_attach = on_common_attach

--vim.fn.sign_define('LightBulbSign', { text = "💡", texthl = "" , linehl= "", numhl= "" })
return lsp_module
