require("utility")
local api = vim.api

local columns = api.nvim_get_option("columns")
local lines = api.nvim_get_option("lines")

local win_props = {
    width = Min({columns - 5, Max({80, columns - 20})}),
    height = Min({lines - 5, Max({20, lines - 20})}),
    col = 10,
    row = 5
}

local function repeat_local(what, time)
    local res = ""
    for i = 0, time do
        what = what .. what
        --res..what
    end
    return res
end
print(repeat_local("A", 5))

local ddd = string.rep(BORDERHORIZONTAl, win_props.width - 2)
local whitespace = string.rep(" ", win_props.width - 2)

local line_top = BORDERTOPLEFT .. ddd .. bBORDERTOPRIGHT
local line_middle = BORDERVERTICAL .. whitespace .. BORDERVERTICAL
local line_bottom = BORDERBOTLEFT .. ddd .. BORDERBOTRIGHT

--local middle_line = string.format(
--"%s%s%s",
--(left_enabled and border_win_options.left) or '',
--string.rep(' ', content_win_options.width),
--(right_enabled and border_win_options.right) or ''
--)
local middle_line = string.format("%s%s%s", line_top, line_middle, line_middle)
print(middle_line)
--print(string.format("%s%s%s",string.rep(line_middle,50)))

function drawbox()
    local opts = {
        relative = "editor",
        width = win_props.width,
        height = win_props.height,
        col = win_props.col,
        row = win_props.row,
        anchor = "NW",
        style = "minimal"
    }
    --local exp = string.rep(line_middle,win_props.width)
    local buf = vim.api.nvim_create_buf(false, true)

    local lines = {}
    lines[1] = line_top
    lines[2] = nil

    local y = 2
    for i = y, win_props.height - 2 do
        lines[i] = line_middle
        y = y + 1
    end

    lines[y] = line_bottom

    vim.api.nvim_buf_set_lines(buf, 0, -1, true, lines)
    local win = vim.api.nvim_open_win(buf, 0, opts)

    local function overlap_controller(padding)
        opts.row = win_props.row + 1
        opts.col = win_props.col + 1

        opts.height = win_props.height - 2
        opts.width = win_props.width - 2
    end
    overlap_controller({1, 2})

    local overlay = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(overlay, 0, -1, true, {"hello", "what"})
    vim.api.nvim_open_win(overlay, true, opts)

    vim.cmd("au BufWipeout <buffer> exe 'bw '.s:buf")
    vim.cmd("hi float guibg=#fff")
    vim.api.nvim_win_set_option(win, "winhl", "Normal:float")
end

function plenary_draw()
    local b = require("plenary")
    b.popup.popup_create(
        "sdasasd",
        {
            border = true,
            --col = win_props.width,
            col = 100,
            width = 100,
            line = win_props.height
        }
    )
end
