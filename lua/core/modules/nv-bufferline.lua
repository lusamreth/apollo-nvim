local bufferline_offsets = {
    {
        filetype = "NvimTree",
        text = "File Explorer",
        text_align = "center"
    },
    {
        filetype = "minimap",
        text = "Minimap",
        text_align = "center"
    },
    {
        filetype = "Outline",
        text = "Symbols",
        text_align = "center"
    },
    {
        filetype = "packer",
        text = "Plugins manager",
        text_align = "center"
    }
}

-- local highlights = {
--     background = {
--         guifg = colors.grey_fg,
--         guibg = colors.black2
--     },
--     -- buffers
--     buffer_selected = {
--         guifg = colors.white,
--         guibg = colors.black,
--         gui = "bold"
--     },
--     buffer_visible = {
--         guifg = colors.light_grey,
--         guibg = colors.black2
--     },
--     -- for diagnostics = "nvim_lsp"
--     error = {
--         guifg = colors.light_grey,
--         guibg = colors.black2
--     },
--     error_diagnostic = {
--         guifg = colors.light_grey,
--         guibg = colors.black2
--     },
--     -- close buttons
--     close_button = {
--         guifg = colors.light_grey,
--         guibg = colors.black2
--     },
--     close_button_visible = {
--         guifg = colors.light_grey,
--         guibg = colors.black2
--     },
--     close_button_selected = {
--         guifg = colors.red,
--         guibg = colors.black
--     },
--
--
--     fill = {
--         guifg = colors.grey_fg,
--         guibg = colors.black2
--     },
--     indicator_selected = {
--         guifg = colors.black,
--         guibg = colors.black
--     },
--     -- modified
--     modified = {
--         guifg = colors.red,
--         guibg = colors.black2
--     },
--     modified_visible = {
--         guifg = colors.red,
--         guibg = colors.black2
--     },
--     modified_selected = {
--         guifg = colors.green,
--         guibg = colors.black
--     },
--     -- separators
--     separator = {
--         guifg = colors.black2,
--         guibg = colors.black2
--     },
--     separator_visible = {
--         guifg = colors.black2,
--         guibg = colors.black2
--     },
--     separator_selected = {
--         guifg = colors.black2,
--         guibg = colors.black2
--     },
--     -- tabs
--     tab = {
--         guifg = colors.light_grey,
--         guibg = colors.one_bg3
--     },
--     tab_selected = {
--         guifg = colors.black2,
--         guibg = colors.nord_blue
--     },
--     tab_close = {
--         guifg = colors.red,
--         guibg = colors.black
--     }
-- }
local comment_fg = "#ffffff"
-- colors for active , inactive uffer tabs
require("bufferline").setup(
    {
        options = {
            -- need to put this at top
            diagnostics = "nvim_lsp",
            buffer_close_icon = "",
            offset = bufferline_offsets,
            modified_icon = "●",
            close_icon = "",
            left_trunc_marker = "",
            view = "multiwindow",
            right_trunc_marker = "",
            max_name_length = 20,
            max_prefix_length = 13,
            tab_size = 25,
            enforce_regular_tabs = true,
            show_buffer_close_icons = true,
            always_show_bufferline = true,
            separator_style = "thin",
            --             custom_filter = function(buf_number)
            --                 local present_type, type =
            --                     pcall(
            --                     function()
            --                         return vim.api.nvim_buf_get_var(buf_number, "term_type")
            --                     end
            --                 )

            --                 if vim.bo[buf_number].filetype ~= "dashboard" then
            --                     return true
            --                 end

            --                 if present_type and type == "vert" or type == "hori" then
            --                     return false
            --                 else
            --                     return true
            --                 end
            --             end,
            diagnostics_indicator = function(_, _, diagnostics_dict)
                local s = " "
                for e, n in pairs(diagnostics_dict) do
                    local sym = e == "error" and " " or (e == "warning" and " " or "")
                    s = s .. sym .. n
                end
                return s
            end
        },
        custom_areas = {
            right = function()
                local result = {}
                local error = vim.lsp.diagnostic.get_count(0, [[Error]])
                local warning = vim.lsp.diagnostic.get_count(0, [[Warning]])
                local info = vim.lsp.diagnostic.get_count(0, [[Information]])
                local hint = vim.lsp.diagnostic.get_count(0, [[Hint]])

                if error ~= 0 then
                    result[1] = {
                        text = "  " .. error,
                        guifg = "#ff6c6b"
                    }
                end

                if warning ~= 0 then
                    result[2] = {
                        text = "  " .. warning,
                        guifg = "#ECBE7B"
                    }
                end

                if hint ~= 0 then
                    result[3] = {
                        text = "  " .. hint,
                        guifg = "#98be65"
                    }
                end

                if info ~= 0 then
                    result[4] = {
                        text = "  " .. info,
                        guifg = "#51afef"
                    }
                end
                return result
            end
        }
    }
)

local opt = {silent = true}
--reset leader key
vim.g.mapleader = " "
--command that adds new buffer and moves to it
--vim.api.nvim_command "com -nargs=? -complete=file_in_path New badd <args> | blast"
vim.api.nvim_set_keymap("n", "<S-b>", ":New ", opt)

--removing a buffer
vim.api.nvim_set_keymap("n", "<S-f>", [[<Cmd>bdelete<CR>]], opt)

-- tabnew and tabprev
vim.api.nvim_set_keymap("n", "<S-l>", [[<Cmd>BufferLineCycleNext<CR>]], opt)
vim.api.nvim_set_keymap("n", "<S-s>", [[<Cmd>BufferLineCyclePrev<CR>]], opt)
