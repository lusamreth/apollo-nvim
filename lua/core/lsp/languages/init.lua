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
store('rust_analyzer', 'rust-lang')

for k, provider in pairs(Providers) do
    provider.on_attach = lsp.on_common_attach(false, nil)
end

require('mason-lspconfig').setup()

require('lsp-setup').setup({
    servers = Providers,
})

require('mason-null-ls').setup({
    automatic_setup = true,
})
-- require('lspconfig').tailwindcss.setup({})
