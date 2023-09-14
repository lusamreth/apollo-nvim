require('lspsaga').setup()

local keymap = vim.keymap.set
local mapper = {}
function mapper.LspSagaExtension(prefix)
    local map = vim.keymap.set

    local nav_prefix = prefix[1]
    local definition_prefix = prefix[2]
    local util_prefix = '<leader>'

    require('lspsaga').setup({})

    local TIMEOUT = 500
    local n = 0
    local timer = vim.loop.new_timer()
    local blocked_cursor = false

    local blocking_saga_cmd = function(cmd)
        return function()
            blocked_cursor = true
            local timer = vim.loop.new_timer()
            if timer ~= nil then
                timer:start(500, 0, function()
                    blocked_cursor = false
                end)
            end
            vim.cmd('Lspsaga ' .. cmd)
        end
    end

    map('n', util_prefix .. 'sl', '<cmd>Lspsaga show_line_diagnostics<CR>')
    map('n', util_prefix .. 'sb', '<cmd>Lspsaga show_buf_diagnostics<CR>')
    map('n', util_prefix .. 'sw', '<cmd>Lspsaga show_workspace_diagnostics<CR>')
    map('n', util_prefix .. 'sc', '<cmd>Lspsaga show_cursor_diagnostics<CR>')
    -- map('n', nav_prefix .. 'p', '<cmd>Lspsaga diagnostic_jump_prev<CR>')

    map('n', nav_prefix .. 'n', blocking_saga_cmd('diagnostic_jump_next'))
    map('n', nav_prefix .. 'p', blocking_saga_cmd('diagnostic_jump_prev'))

    map('n', definition_prefix .. 't', blocking_saga_cmd('goto_type_definition'))
    map('n', definition_prefix .. 'h', blocking_saga_cmd('lsp_finder'))
    map('n', definition_prefix .. 'p', blocking_saga_cmd('peek_definition'))

    local group = vim.api.nvim_create_augroup('Line Diagnostics', { clear = true })
    local command_id = vim.api.nvim_create_autocmd('CursorHold', {
        callback = function()
            if not blocked_cursor then
                vim.cmd('Lspsaga show_line_diagnostics ++unfocus')
            end
        end,
        group = group,
    })

    map('n', util_prefix .. 'k', '<cmd>Lspsaga hover_doc<CR>')
    map('n', 'rn', '<cmd>Lspsaga rename<CR>')
    map('n', util_prefix .. 'x', '<cmd>Lspsaga code_action<CR>')
    map('n', util_prefix .. 'o', '<cmd>Lspsaga outline<CR>')

    -- Call hierarchy
    map('n', util_prefix .. 'ci', '<cmd>Lspsaga incoming_calls<CR>')
    map('n', util_prefix .. 'co', '<cmd>Lspsaga outgoing_calls<CR>')

    -- Floating terminal
    map({ 'n', 't' }, '<A-d>', '<cmd>Lspsaga term_toggle<CR>')
end

return mapper
