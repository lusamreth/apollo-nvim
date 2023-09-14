local Input = require('nui.input')
local Layout = require('nui.layout')
local Popup = require('nui.popup')
local menu = access_module('nv-pilot.nv-menu')
local api = access_module('nv-pilot.api')
local NuiText = require('nui.text')

local params = vim.lsp.util.make_position_params()

local popup_options = {
    -- border for the window
    border = {
        style = 'rounded',
        text = {
            top = '[Rename]',
            top_align = 'left',
        },
    },
    -- highlight for the window.
    highlight = 'Normal:Normal',
    -- place the popup window relative to the
    -- buffer position of the identifier
    relative = {
        type = 'buf',
        position = {
            -- this is the same `params` we got earlier
            row = params.position.line,
            col = params.position.character,
        },
    },
    -- position the popup window on the line below identifier
    position = {
        row = 1,
        col = 0,
    },
    -- 25 cells wide, should be enough for most identifier names
    size = {
        width = 25,
        height = 1,
    },
}

local input_text = ''
local input = Input(popup_options, {
    -- set the default value to current name
    -- default_value = curr_name,
    -- pass the `on_submit` callback function we wrote earlier
    on_submit = function(text)
        print('testing ui', text)
    end,
    on_change = function(text)
        print('onchange ui', text)
        input_text = text
    end,
    on_close = function() end,
    prompt = '',
})

local convo_screen = Popup({ border = 'double' })
local prompts = {}

local on_enter_func = function()
    table.insert(prompts, input_text)
    vim.pretty_print(prompts)
    vim.api.nvim_buf_set_lines(convo_screen.bufnr, 0, -1, false, prompts)
    vim.api.nvim_buf_set_lines(input.bufnr, 0, 1, false, { '' })
    input_text = ''
end

input:map('n', '<CR>', function()
    on_enter_func()

    api.make_call('https://api.pawan.krd/v1/chat/completions', { message = 'bruh' }, function(result)
        table.insert(prompts, result)
    end)

    -- do something
end, { noremap = true })

input:map('n', '<C-c>', function()
    -- on_enter_func()
    -- do something
end, { noremap = true })

input:map('i', '<CR>', function()
    print('on enter [insert]', input_text)
    on_enter_func()
    -- do something
end, { noremap = true })

local layout = Layout(
    {
        position = '50%',
        size = {
            width = 80,
            height = '60%',
        },
    },
    Layout.Box({
        -- Layout.Box(menu.menu, { size = '40%' }),
        Layout.Box(convo_screen, { size = '80%' }),
        Layout.Box(input, { size = '20%' }),
    }, { dir = 'col' })
)

-- for _, mode in ipairs({ 'n', 'i' }) do
--     input:map(mode, Config.options.edit_with_instructions.keymaps.accept, function()
--         input.input_props.on_close()
--         local lines = vim.api.nvim_buf_get_lines(output_window.bufnr, 0, -1, false)
--         vim.api.nvim_buf_set_text(bufnr, start_row - 1, start_col - 1, end_row - 1, end_col, lines)
--         vim.notify('Successfully applied the change!', vim.log.levels.INFO)
--     end, { noremap = true })
-- end
local function render_test()
    print('render test')
    layout:mount()
end

-- layout:mount()
-- vim.ke
vim.keymap.set('n', '<Leader>rx', render_test, { noremap = true, silent = true })
