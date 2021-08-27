require("formatter").setup(
    {
        logging = false,
        filetype = {
            javascript = {
                -- prettier
                function()
                    return {
                        exe = "prettier",
                        args = {
                            "--stdin-filepath",
                            vim.api.nvim_buf_get_name(0),
                            "--single-quote"
                        },
                        stdin = true
                    }
                end
            },
            rust = {
                -- Rustfmt
                function()
                    return {exe = "rustfmt", args = {"--edition=2018", "--emit=stdout"}, stdin = true}
                end
            },
            lua = {
                -- luafmt
                function()
                    return {
                        exe = "luafmt",
                        args = {"--indent-count", 4, "--stdin"},
                        -- 					args = {

                        -- 						"--stdin-filepath",
                        -- 						vim.api.nvim_buf_get_name(0),
                        -- 					},
                        stdin = true
                    }
                end
            }
        }
    }
)

-- nnoremap <silent> <leader>f :Format<CR>

-- auto run
function ExecFormat()
    vim.api.nvim_exec(
        [[
    augroup FormatAutogroup
      autocmd!
      echo "Format file"
      autocmd BufWritePost *.js,*.rs,*.lua FormatWrite
    augroup END
    ]],
        true
    )
end

ExecFormat()
