-- lua programming
-- could also be used for scripting

-- lua lsp !!
local pylang = access_core('lsp.languages.python-lang')
require('neodev').setup({
    -- add any options here, or leave empty to use the default settings
})
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
    -- 'cmake-language-server',
    'tsserver',
    -- 'arduino_language_server',
    -- 'rome',
    'clangd',
    'cssls',
    -- 'sumneko_lua',
    'yamlls',

    'dockerls',
    'lemminx',
    -- 'emmet_ls',
    -- 'tailwindcss',
}

UtilityProviders = {}

UtilityProviders.bashls = {
    filetypes = { 'sh', 'zsh' },
}

UtilityProviders.arduino_language_server = {
    cmd = {
        'arduino-language-server',
        '-cli',
        '/usr/bin/arduino-cli',
        '-cli-config',
        '/home/lusamreth/.arduino15/arduino-cli.yaml',
        '-clangd',
        '/usr/bin/clangd',
    },
}
UtilityProviders.pyright = {
    before_init = function(_, config)
        config.settings.python.pythonPath = pylang.get_python_path(config.root_dir)
    end,
}

for i, server in pairs(servers) do
    UtilityProviders[server] = {}
end

UtilityProviders.lua_ls = LUACONF

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

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
