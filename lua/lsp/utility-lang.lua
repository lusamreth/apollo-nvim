-- lua programming
--
-- could also be used for scripting
-- [future] using json to configure stuff

-- lua lsp !!
local sumneko_root_path = DATA_PATH .. "/lspinstall/lua"
local sumneko_binary = sumneko_root_path .. "/sumneko-lua-language-server"

-- copied from nvcode project
require'lspconfig'.lua.setup {
    cmd = {sumneko_binary, "-E", sumneko_root_path .. "/main.lua"},
    on_attach = require'lsp'.on_common_attach(),
    settings = {
        Lua = {
            runtime = {
                -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                version = 'LuaJIT',
                -- Setup your lua path
                path = vim.split(package.path, ';')
            },
            diagnostics = {
                -- Get the language server to recognize the `vim` global
                globals = {'vim'}
            },
            workspace = {
                -- Make the server aware of Neovim runtime files
                library = {
                      [vim.fn.expand('$VIMRUNTIME/lua')] = true,
                      [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
                      ["/usr/share/nvim/runtime/lua"] = true,
                      ["/usr/share/nvim/runtime/lua/vim"] = true,
                      ["/usr/share/nvim/runtime/lua/vim/lsp"] = true,
                },
                maxPreload = 50000
            }
        }
    }
}

--fix this shit
require"lspconfig".efm.setup {
    init_options = {documentFormatting = true},
    filetypes = {"lua"},
    settings = {
        --rootMarkers = {".git/"},
        languages = {
            lua = {
                {
                    formatCommand = "lua-format -i --no-keep-simple-function-one-line --no-break-after-operator --column-limit=150 --break-after-table-lb",
                    formatStdin = true
                }
            }
        }
    }
}

require"lspconfig".bash.setup {

}

--vim.cmd("BufWritePre *.lua lua vim.lsp.buf.formatting_sync(nil, 100)")
vim.api.nvim_set_keymap("n","zf","<cmd>lua vim.lsp.buf.formatting_sync(nil, 100)<CR>",{noremap = true})
require'lspconfig'.vim.setup = {
    on_attach = require'lsp'.on_common_attach()
}
