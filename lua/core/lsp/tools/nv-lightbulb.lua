-- Showing defaults
require("nvim-lightbulb").update_lightbulb(
    {
        sign = {
            enabled = true,
            -- Priority of the gutter sign
            priority = 30
        },
        float = {
            enabled = false,
            -- Text to show in the popup float
            text = "💡",
            -- Available keys for window options:
            -- - height     of floating window
            -- - width      of floating window
            -- - wrap_at    character to wrap at for computing height
            -- - max_width  maximal width of floating window
            -- - max_height maximal height of floating window
            -- - pad_left   number of columns to pad contents at left
            -- - pad_right  number of columns to pad contents at right
            -- - pad_top    number of lines to pad contents at top
            -- - pad_bottom number of lines to pad contents at bottom
            -- - offset_x   x-axis offset of the floating window
            -- - offset_y   y-axis offset of the floating window
            -- - anchor     corner of float to place at the cursor (NW, NE, SW, SE)
            win_opts = {
                offset_x = 5,
                max_height = 20,
                max_width = 20,
                pad_left = 5,
                pad_right = 5,
                winblend = 76
            }
        },
        virtual_text = {
            enabled = true,
            -- Text to show at virtual text
            text = "💡"
        }
    }
)
vim.cmd([[autocmd CursorHold,CursorHoldI * lua require'nvim-lightbulb'.update_lightbulb()]])

vim.api.nvim_command("highlight LightBulbFloatWin guifg=#fff guibg=#111")
vim.api.nvim_command("highlight LightBulbVirtualText guifg=#135512 guibg=#193010")
