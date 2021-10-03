require("utility")
require("utility.var")
-- opts ; border, height,width,padding,margin
function SendToWindow(content, opts)
    local columns = vim.api.nvim_get_option("columns")
    local opts = opts or {}

    --early return2
    if opts.border == false then
        return
    end
    --local max_width = math.floor(columns - (columns / 10))
    local max_width = math.floor(columns / 2)
    --local max_width = 100
    for _, line in pairs(content) do
        local line_len = line:len()
        if line_len > max_width then
            max_width = line_len
        end
    end
    local len_arr = {}
    for i, line in pairs(content) do
        len_arr[i] = #line
    end
    local max_length = FindMax(len_arr)
    local left, right, top, bottom
    print(max_length)

    if #opts.padding == 2 then
        local vert = opts.padding[2]
        right, left = vert, vert
        local horz = opts.padding[1]
        top, bottom = horz, horz
    else
        top, bottom = opts.padding[1], opts.padding[2]
        left, right = opts.padding[3], opts.padding[4]
    end

    local ptop = string.rep(" ", top)
    local pbot = string.rep(" ", bottom)
    local pright = string.rep(" ", right)
    local pleft = string.rep(" ", left)

    local j = 2
    local lines = {}

    table.insert(lines, j, ptop)
    local line_num = #lines + top
    for i, line in pairs(content) do
        lines[i] =
            string.format(
            "%s%s%s%s%s%s",
            BORDERVERTICAL,
            ----------------------------------------
            pleft,
            line, -- content line
            pright,
            string.rep(" ", max_length - len_arr[i]), -- <padding
            ----------------------------------------
            BORDERVERTICAL
        )
    end

    local full_length = max_length + left + right
    --insert at first index
    table.insert(lines, 1, BORDERTOPLEFT .. string.rep(BORDERHORIZONTAL, full_length) .. BORDERTOPRIGHT)
    table.insert(lines, j, ptop)
    table.insert(lines, BORDERBOTLEFT .. string.rep(BORDERHORIZONTAL, full_length) .. BORDERBOTRIGHT)

    --print(max_length)
    -- implementing padding?

    --print_r(lines)
    local overlay = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(overlay, 0, -1, true, lines)

    local win_props = {
        --width = Min({columns - 5,Max({80,columns - 20})}),
        --height = Min({lines - 5,Max({20,lines - 20})},
        width = 60,
        height = #lines,
        col = max_width / 2,
        row = 5
    }

    local win_opts = {
        relative = "editor",
        width = math.ceil(full_length + 2),
        height = #lines,
        col = win_props.col,
        row = win_props.row,
        anchor = "NW",
        style = "minimal"
    }
    --local win_opts =
    vim.cmd("au BufWipeout <buffer> exe 'bw '.s:buf")
    vim.cmd("setlocal winhighlight=Normal:MarkdownError")
    local red = "#000000"
    local nord = "#81A1C1"

    local highlight_float = "hi float guifg=" .. red .. " guibg=" .. nord
    vim.cmd(highlight_float)

    local win = vim.api.nvim_open_win(overlay, true, win_opts)
    vim.api.nvim_win_set_option(win, "winhl", "Normal:float")
    return win
end

local function close_win(win)
    --print("win",win)
    return vim.api.nvim_win_close(win, true)
end

local state = 1
local prev

function Toggle_win(content)
    --print(state)
    if state == 1 then
        prev =
            SendToWindow(
            content,
            {
                padding = {10, 5}
            }
        )
        -- reset
        state = 0
    else
        if prev == nil then
            return
        end
        close_win(prev)
        state = 1
    end
end

Text = ""
vim.api.nvim_set_keymap("n", "zo", "<cmd>lua Toggle_win{Text}<CR>", {noremap = true})
vim.api.nvim_set_keymap("n", "zr", "<cmd>luafile %<CR>", {noremap = true})
--vim.cmd("nnoremap z lua add_border{'hello girl'}<CR>")
--add_border{"hellogurl","bamboo"}

-- we need to apply padding before calculating max_length
local function apply_padding(line, padding)
    local p = padding or {0, 0}
    if type(padding) == "number" then
        p = {padding, padding} -- what the fk ?
    end

    local left, right = p[1], p[2]
    return string.format("%s%s%s", string.rep("a", left), line, string.rep("a", right))
end
