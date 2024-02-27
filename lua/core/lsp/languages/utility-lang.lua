-- lua programming
-- could also be used for scripting

-- lua lsp !!
local pylang = access_core('lsp.languages.python-lang')

require('neodev').setup(
    {
        library = {
            enabled = true, -- when not enabled, neodev will not change any settings to the LSP server
            -- these settings will be used for your Neovim config directory
            runtime = true, -- runtime path
            types = true, -- full signature, docs and completion of vim.api, vim.treesitter, vim.lsp and others
            -- plugins = true, -- installed opt or start plugins in packpath
            -- you can also specify the list of plugins to make available as a workspace library
            plugins = { 'nvim-treesitter', 'plenary.nvim', 'telescope.nvim' },
        },
        setup_jsonls = true, -- configures jsonls to provide completion for project specific .luarc.json files
        -- for your Neovim config directory, the config.library settings will be used as is
        -- for plugin directories (root_dirs having a /lua directory), config.library.plugins will be disabled
        -- for any other directory, config.library.enabled will be set to false
        override = function(root_dir, options) end,
        -- With lspconfig, Neodev will automatically setup your lua-language-server
        -- If you disable this, then you have to set {before_init=require("neodev.lsp").before_init}
        -- in your lsp start options
        lspconfig = true,
        -- much faster, but needs a recent built of lua-language-server
        -- needs lua-language-server >= 3.6.0
        pathStrict = true,
    }
    -- add any options here, or leave empty to use the default settings
)

LUACONF = {
    on_init = function(client)
        local path = client.workspace_folders[1].name
        if not vim.loop.fs_stat(path .. '/.luarc.json') and not vim.loop.fs_stat(path .. '/.luarc.jsonc') then
            client.config.settings = vim.tbl_deep_extend('force', client.config.settings, {
                Lua = {
                    runtime = {
                        -- Tell the language server which version of Lua you're using
                        -- (most likely LuaJIT in the case of Neovim)
                        version = 'LuaJIT',
                    },
                    completion = {
                        callSnippet = 'Replace',
                    },

                    diagnostics = {
                        -- Get the language server to recognize the `vim` global
                        globals = { 'vim' },
                    },
                    -- Make the server aware of Neovim runtime files
                    workspace = {
                        checkThirdParty = false,
                        library = {
                            vim.env.VIMRUNTIME,
                            -- "${3rd}/luv/library"
                            -- "${3rd}/busted/library",
                        },
                        -- Do not send telemetry data containing a randomized but unique identifier
                        telemetry = {
                            enable = false,
                        },
                        -- or pull in all of 'runtimepath'. NOTE: this is a lot slower
                        -- library = vim.api.nvim_get_runtime_file("", true)
                    },
                    single_file_support = true,
                },
            })

            client.notify('workspace/didChangeConfiguration', { settings = client.config.settings })
        end
        return true
    end,
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
    'jdtls',
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
UtilityProviders.jdtls = {
    cmd = { 'jdtls' },
    filetypes = { 'java' },
    root_dir = {
        -- Single-module projects
        {
            'build.xml', -- Ant
            'pom.xml', -- Maven
            'settings.gradle', -- Gradle
            'settings.gradle.kts', -- Gradle
        },
        -- Multi-module projects
        { 'build.gradle', 'build.gradle.kts' },
    } or vim.fn.getcwd(),
}

UtilityProviders.pyright = {
    filetypes = { 'python' },
    on_attach = require('cmp').on_attach,
    before_init = function(_, config)
        config.settings.python.pythonPath = pylang.get_python_path(config.root_dir)
    end,
}

for i, server in pairs(servers) do
    UtilityProviders[server] = {
        -- on_attach =
    }
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
        'atidy',
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
