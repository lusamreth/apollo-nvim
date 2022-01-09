local lsp_installer = require('nvim-lsp-installer')
local lsp = access_core('lsp.init')
access_core('lsp.languages.utility-lang')
access_core('lsp.languages.rust-lang')

-- Providers = {
--     unpack(UtilityProviders),
--     unpack(RustProvider)
-- }
-- Providers = Utils.table_merge(0, UtilityProviders, RustProvider)
Providers = UtilityProviders
Providers.rust_analyzer = RustProvider

-- print("PROVIDERS : ", vim.inspect(Providers))
lsp_installer.on_server_ready(function(server)
    local opts = {}

    -- (optional) Customize the options passed to the server
    -- print(vim.inspect(server))
    if Providers[server.name] then
        opts = Providers[server.name]
        opts.on_attach = lsp.on_common_attach()
        server:setup(opts)
    end
    -- This setup() function is exactly the same as lspconfig's setup function.
    -- Refer to https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
end)
