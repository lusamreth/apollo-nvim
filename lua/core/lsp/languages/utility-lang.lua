-- lua programming
-- could also be used for scripting

-- lua lsp !!
-- local sumneko_root_path = LSP_REPO .. "lua"
-- local sumneko_binary = sumneko_root_path .. "/sumneko-lua-language-server"

LUACONF = {
    settings = {
        Lua = {
            runtime = {
                -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                version = 'LuaJIT',
            },
            diagnostics = {
                -- Get the language server to recognize the `vim` global
                globals = { 'vim' },
            },
            workspace = {
                -- Make the server aware of Neovim runtime files
                library = vim.api.nvim_get_runtime_file('', true),
            },
            -- Do not send telemetry data containing a randomized but unique identifier
            telemetry = {
                enable = false,
            },
        },
    },
    single_file_support = true,
}
-- local server
local servers = {
    'bashls',
    'pyright',
    'vuels',
    'sumneko_lua',
    'yamlls',
}

-- for _, name in pairs(servers) do
--     local server_is_found, server = lsp_installer.get_server(name)
--     if server_is_found then if not server:is_installed() then
--             print("Installing " .. name)
--             server:install()
--         end
--     end
-- end
--local util = require("lspconfig").utils
-- copied from nvcode project
-- lspconfig.sumneko_lua.setup(LUACONF)

UtilityProviders = {}

UtilityProviders.bashls = {
    filetypes = { 'sh', 'zsh' },
}

UtilityProviders.pyright = {
    filetypes = { 'python' },
    python = {
        analysis = {
            autoSearchPaths = true,
            useLibraryCodeForTypes = true,
        },
    },
}

UtilityProviders.sumneko_lua = LUACONF
UtilityProviders.jsonls = {}
UtilityProviders.lemminx = {}
UtilityProviders.tsserver = {}

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
UtilityProviders.emmet_ls = {}

-- UtilityProviders.rome = {}

local ls = require('luasnip')

-- Every unspecified option will be set to the default.
ls.config.set_config({
    history = true,
    -- Update more often, :h events for more info.
    updateevents = 'TextChanged,TextChangedI',
})

ls.snippets = {
    all = {},
    html = {},
}

-- enable html snippets in javascript/javascript(REACT)
ls.snippets.javascript = ls.snippets.html
ls.snippets.javascriptreact = ls.snippets.html
ls.snippets.typescriptreact = ls.snippets.html

require('luasnip/loaders/from_vscode').load({ include = { 'html' } })

--vim.cmd("BufWritePre *.lua lua vim.lsp.buf.formatting_sync(nil, 100)")
vim.api.nvim_set_keymap('n', 'zf', '<cmd>lua vim.lsp.buf.formatting_sync(nil, 100)<CR>', { noremap = true })

return UtilityProviders
