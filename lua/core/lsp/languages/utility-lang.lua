-- lua programming
-- could also be used for scripting

-- lua lsp !!
local sumneko_root_path = LSP_REPO .. "lua"
local sumneko_binary = sumneko_root_path .. "/sumneko-lua-language-server"

local lsp = access_core("lsp.init")
--local util = require("lspconfig").utils
-- copied from nvcode project
require("lspconfig").lua.setup(
    {
        cmd = {sumneko_binary, "-E", sumneko_root_path .. "/main.lua"},
        on_attach = lsp.on_common_attach(),
        settings = {
            Lua = {
                runtime = {
                    -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                    version = "LuaJIT",
                    -- Setup your lua path
                    path = vim.split(package.path, ";")
                },
                diagnostics = {
                    -- Get the language server to recognize the `vim` global
                    globals = {"vim"}
                },
                workspace = {
                    -- Make the server aware of Neovim runtime files
                    library = {
                        [vim.fn.expand("$VIMRUNTIME/lua")] = true,
                        [vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
                        ["/usr/share/nvim/runtime/lua"] = true,
                        ["/usr/share/nvim/runtime/lua/vim"] = true,
                        ["/usr/share/nvim/runtime/lua/vim/lsp"] = true
                    },
                    maxPreload = 50000
                }
            }
        }
    }
)

--fix this shit
require("lspconfig").efm.setup(
    {
        init_options = {documentFormatting = true},
        filetypes = {"lua"},
        on_attach = lsp.on_common_attach(),
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
)

local bashls_server = LSP_REPO .. "bash/node_modules/bash-language-server/bin/main.js"
require("lspconfig").bash.setup(
    {
        filetypes = {"sh", "zsh"},
        cmd = {bashls_server, "start"},
        on_attach = lsp.on_common_attach(false)
    }
)

local pyright = LSP_REPO .. "python/node_modules/pyright/langserver.index.js"
require("lspconfig").python.setup(
    {
        filetypes = {"python"},
        cmd = {pyright, "--stdio"},
        on_attach = lsp.on_common_attach(false),
        python = {
            analysis = {
                autoSearchPaths = true,
                diagnosticMode = "workspace",
                useLibraryCodeForTypes = true
            }
        }
    }
)

--vim.cmd("BufWritePre *.lua lua vim.lsp.buf.formatting_sync(nil, 100)")
vim.api.nvim_set_keymap("n", "zf", "<cmd>lua vim.lsp.buf.formatting_sync(nil, 100)<CR>", {noremap = true})
