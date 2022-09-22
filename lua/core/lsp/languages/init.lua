local lsp = access_core('lsp.init')

Providers = access_core('lsp.languages.' .. 'utility-lang')
-- print(vim.inspect(Providers))
-- want to cache certain functionality or import when attach !
function store(name, filename)
    local fetch = function()
        o = access_core('lsp.languages.' .. filename)
        return o
    end

    Providers[name] = {
        fetch = fetch,
    }
end

lookup_files = {
    rust_analyzer = 'rust-lang',
    utility = 'utility-lang',
}
-- access_core('lsp.languages.python-lang')
store('rust_analyzer', 'rust-lang')

for k, provider in pairs(Providers) do
    provider.on_attach = lsp.on_common_attach(false, nil)
end

require('nvim-lsp-installer').setup({
    automatic_installation = true, -- automatically detect which servers to install (based on which servers are set up via lspconfig)
    ui = {
        icons = {
            server_installed = '✓',
            server_pending = '➜',
            server_uninstalled = '✗',
        },
    },
})

require('nvim-lsp-setup').setup({
    servers = Providers,
})

-- require('lspconfig').tailwindcss.setup({})
