local null_ls = require('null-ls')
local helpers = require('null-ls.helpers')

local function write_to_buf(data)
    local bufnr = vim.api.nvim_get_current_buf()
    local new_lines

    new_lines = vim.split(data, '\n')
    -- write contents
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, new_lines)
    print('WRITING TO BUFF')
    -- vim.cmd('w')
end

function BuildCustomFormatter(writer, error_handler, format_type)
    -- good old printer
    error_handler = error_handler or function(err)
        print('ERROR', err)
    end

    writer = writer or write_to_buf

    return function(config)
        local cmd = config['exe']
        local args = config['args']
        table.insert(args, '$FILENAME')
        local ft = config['filetype']

        return {
            name = config['name'],
            method = null_ls.methods.FORMATTING,
            -- method = null_ls.methods.DIAGNOSTICS,
            -- name = 'custom source',
            filetypes = ft,
            generator = helpers.formatter_factory({
                command = cmd,
                args = args,
                format = format_type or 'raw',
                on_output = function(params, done)
                    -- print('=>', vim.inspect(params))
                    local err = params.err
                    -- run custom error handling
                    if err ~= nil then
                        error_handler(err)
                        return done()
                    else
                        local output = params.output
                        writer(output)
                    end
                    return done()
                end,
            }),
        }
    end
end
