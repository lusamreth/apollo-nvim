-- lua programming
-- could also be used for scripting

-- lua lsp !!
-- local sumneko_root_path = LSP_REPO .. "lua"
-- local sumneko_binary = sumneko_root_path .. "/sumneko-lua-language-server"
local pylang = access_core('lsp.languages.python-lang')
-- local root_pattern = require('lspconfig').util.root_pattern
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
    --'pyright',
    'vuels',
    'html',
    'tsserver',
    'arduino_language_server',
    -- 'rome',

    'cssls',
    -- 'sumneko_lua',
    'yamlls',

    'dockerls',

    'lemminx',
    -- 'emmet_ls',
    -- 'tailwindcss',
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
    before_init = function(_, config)
        config.settings.python.pythonPath = pylang.get_python_path(config.root_dir)
    end,
}
-- UtilityProviders.pyright = {
--     filetypes = { 'python' },
--     python = {
--         analysis = {
--             autoSearchPaths = true,
--             useLibraryCodeForTypes = true,
--         },
--     },
--     root_dir = root_pattern('.venv'),
-- }
for i, server in pairs(servers) do
    UtilityProviders[server] = {}
end

UtilityProviders.sumneko_lua = LUACONF

-- UtilityProviders.jsonls = {}
-- UtilityProviders.lemminx = {}
-- UtilityProviders.tsserver = {
--     capabilities = {

--     }
-- }
-- UtilityProviders.dockerls = {}
-- UtilityProviders.emmet_ls = {}

-- UtilityProviders.rust_analyzer = {}

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

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
UtilityProviders.intelephense = {
    -- Add wordpress to the list of stubs
    stubs = {
        'apache',
        'bcmath',
        'bz2',
        'calendar',
        'com_dotnet',
        'Core',
        'ctype',
        'curl',
        'date',
        'dba',
        'dom',
        'enchant',
        'exif',
        'FFI',
        'fileinfo',
        'filter',
        'fpm',
        'ftp',
        'gd',
        'gettext',
        'gmp',
        'hash',
        'iconv',
        'imap',
        'intl',
        'json',
        'ldap',
        'libxml',
        'mbstring',
        'meta',
        'mysqli',
        'oci8',
        'odbc',
        'openssl',
        'pcntl',
        'pcre',
        'PDO',
        'pdo_ibm',
        'pdo_mysql',
        'pdo_pgsql',
        'pdo_sqlite',
        'pgsql',
        'Phar',
        'posix',
        'pspell',
        'readline',
        'Reflection',
        'session',
        'shmop',
        'SimpleXML',
        'snmp',
        'soap',
        'sockets',
        'sodium',
        'SPL',
        'sqlite3',
        'standard',
        'superglobals',
        'sysvmsg',
        'sysvsem',
        'sysvshm',
        'tidy',
        'tokenizer',
        'xml',
        'xmlreader',
        'xmlrpc',
        'xmlwriter',
        'xsl',
        'Zend OPcache',
        'zip',
        'zlib',
        'wordpress',
        'phpunit',
    },
    diagnostics = {
        enable = true,
    },
}
-- require('luasnip/loaders/from_vscode').load({ include = { 'html' } })
--vim.cmd("BufWritePre *.lua lua vim.lsp.buf.formatting_sync(nil, 100)")
vim.api.nvim_set_keymap('n', 'zf', '<cmd>lua vim.lsp.buf.format()<CR>', { noremap = true })

-- must name Dockerfile
-- require('lspconfig').dockerls.setup({})

return UtilityProviders
