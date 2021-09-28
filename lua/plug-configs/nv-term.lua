local already_open = 0
local panel_color = {"#3c3836", "#fbf1c7"}
local function term_highlighting()
    vim.cmd(string.format("highlight DarkenedPanel guibg=%s guifg=%s", panel_color[1], panel_color[2]))
    vim.cmd("highlight DarkenedStatusline gui=NONE guibg=" .. panel_color[1])
    vim.cmd("highlight DarkenedStatuslineNC cterm=italic gui=NONE guibg=" .. panel_color[1])
    already_open = already_open + 1
end

vim.cmd(string.format("highlight DarkenedPanel guibg=%s,guifg=%s", panel_color[1], panel_color[2]))
require("toggleterm").setup(
    {
        -- size can be a number or function which is passed the current terminal
        size = function(term)
            if already_open == 0 then
                term_highlighting()
            end
            if term.direction == "horizontal" then
                return 12
            elseif term.direction == "vertical" then
                return vim.o.columns * 0.4
            end
        end,
        open_mapping = [[<c-\>]],
        hide_numbers = true, -- hide the number column in toggleterm buffers
        shade_filetypes = {},
        shade_terminals = true,
        shading_factor = "<number>", -- the degree by which to darken to terminal colour, default: 1 for dark backgrounds, 3 for light
        start_in_insert = true,
        persist_size = true,
        --direction = 'vertical' | 'horizontal' | 'window' | 'float',
        close_on_exit = true, -- close the terminal window when the process exits
        --direction = 'vertical',
        direction = "horizontal",
        shell = vim.o.shell, -- change the default shell
        -- This field is only relevant if direction is set to 'float'
        float_opts = {
            -- The border key is *almost* the same as 'nvim_win_open'
            -- see :h nvim_win_open for details on borders however
            -- the 'curved' border is a custom border type
            -- not natively supported but implemented in this plugin.
            --border = 'single' | 'double' | 'shadow' | 'curved' | ... other options supported by win open
            border = "curved",
            width = 60,
            height = 20,
            winblend = 3,
            -- use to change background color
            --highlight DarkenedPanel guibg,guifg
            highlights = {
                border = "Normal",
                background = "Normal"
            }
        }
    }
)

--custom terminal

local Terminal = require("toggleterm.terminal").Terminal

function buildShTerm()
    local filename = vim.fn.expand("%:t")
    local current_dir = vim.cmd("pwd")

    if filename == "" then
        return
    end

    local command = "strat -u void shellcheck " .. filename
    local shellcheck =
        Terminal:new(
        {
            cmd = command,
            --cmd = "ls",
            direction = "horizontal",
            dir = current_dir,
            hidden = false,
            on_open = function(term)
                vim.cmd("startinsert!")
                vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", {noremap = true, silent = true})
            end,
            on_close = function(term)
                vim.cmd("Closing terminal")
            end
        }
    )
    return shellcheck
end

function SHCHECK()
    local shellcheck = buildShTerm()
    if shellcheck ~= nil then
        shellcheck:toggle()
    else
        print("empty file!")
    end
end

require("utility")
Nnoremap("<C-l>", "lua SHCHECK()", {silent = false})

-- local save_hook = {
-- 	{ "BufEnter,BufRead", "*sh*", "lua print('init bash savehook')" },
-- 	{ "BufWritePost", "lua SHCHECK" },
-- }
-- Create_augroup(save_hook, "bashtermhook")
--Nnoremap("<C-t>","lua vim.cmd('ToggleTerm')",{})
