local lsp_installer = require('nvim-lsp-installer')
local lsp = access_core('lsp.init')

--Providers = {
--    unpack(UtilityProviders),
--    unpack(RustProvider)
--}
--Providers = Utils.table_merge(0, UtilityProviders, RustProvider)
--

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

-- print("PROVIDERS : ", vim.inspect(Providers))
lsp_installer.on_server_ready(function(server)
    local opts = {}

    -- (optional) Customize the options passed to the server
    -- print(vim.inspect(server))
    if Providers[server.name] then
        opts = Providers[server.name]
        assert(opts ~= nil, 'the fetched option is empty!!')
        opts.on_attach = lsp.on_common_attach(false, opts.fetch or nil)
        server:setup(opts)
    end
    -- This setup() function is exactly the same as lspconfig's setup function.
    -- Refer to https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
end)

--require('py_lsp').setup({
--    on_attach = lsp.on_common_attach(false),
--})
