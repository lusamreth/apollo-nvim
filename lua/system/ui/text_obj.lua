local store = function(f, args)
    return function()
        if type(args) == "table" then
            args = unpack(args)
        end
        return f(args)
    end
end

local function cannonicalize(conf)
    local res
    if #conf == 2 then
        res = {
            x = conf[1],
            y = conf[2]
        }
    else
        res = {
            x = {conf[1], conf[2]},
            y = {conf[3], conf[4]}
        }
    end

    return res
end

local function parse_padding(padding)
    padding = cannonicalize(padding)
    local function check_if_pad_num(conf)
        local newcfg = {}
        for name, c in pairs(conf) do
            if type(c) == "number" then
                newcfg[name] = {}
                newcfg[name][1] = c
                newcfg[name][2] = c
            else
                return
            end
        end

        if newcfg == {} then
            return nil
        else
            return newcfg
        end
    end

    padding = check_if_pad_num(padding) or padding
    local x, y
    x = padding["x"]
    y = padding["y"]

    local vert_padding = {x[1], x[2] or x[1]}
    local hori_padding = {y[1], y[2] or y[1]}

    return vert_padding, hori_padding
end

local get_content_maxlength = function(contents)
    local len_arr =
        vim.tbl_map(
        function(e)
            return #e
        end,
        contents
    )
    return FindMax(len_arr)
end

local extract_property = function(content, config)
    local property = {}

    local corner_len = 1
    local max_length = get_content_maxlength(content)

    property["line_length"] = max_length
    local pv, ph = parse_padding(config["padding"])
    property["padding"] = {pv, ph}
    property["whole_length"] = Sum(pv or {}) + max_length + corner_len
    property["max_length"] = max_length
    property["content"] = content

    return property
end
local function build_add_border(add_dash, fillhalf)
    return function(res, property)
        local callstack = {
            store(fillhalf, "top"),
            function()
                vim.tbl_map(
                    function(content)
                        table.insert(res, add_dash(content, property["max_length"]))
                    end,
                    property["content"]
                )
            end,
            store(fillhalf, "bottom")
        }
        return callstack
    end
end

local function apply_padding(s, p)
    local padl = string.rep(" ", p[1])
    local padr = string.rep(" ", p[2])

    return padl .. s .. padr
end

-- ++ text_obj: important for CreateWin to determine
-- how the text will be rendered on screen
-- ++configurations:
-- -border:bool
-- -padding:{l,r,h,w} or {lr,hw} ==> l = r, h = w
-- -

Tobj = {}

local create_text_obj = function(contents, config)
    if type(contents) == "string" then
        contents = {contents}
    end
    local max_length = get_content_maxlength(contents)
    local property = extract_property(contents, config)
    local vert_padding, hori_padding = unpack(property["padding"])

    local function append_border(s)
        return BORDERHORIZONTAL .. s .. BORDERHORIZONTAL
    end

    local whole_length = property["whole_length"]

    local lines = {}

    local add_border_each_line = function(str, maxLen)
        local each_space = maxLen - #str
        local space = string.rep(" ", each_space)
        local fill_gap = function(s)
            return s .. space
        end

        return append_border(apply_padding(fill_gap(str), vert_padding))
    end

    local function make_insert_vpadding(v_pad, has_border)
        local txt
        if has_border then
            txt = add_border_each_line("", max_length)
        else
            txt = ""
        end

        return function()
            for _ = 1, v_pad do
                table.insert(lines, txt)
            end
        end
    end

    local function get_roof(half_type)
        local corner
        local l = whole_length - 1
        local roof = string.rep(BORDERVERTICAL, l)

        if half_type == "bottom" then
            corner = {BORDERBOTLEFT, BORDERBOTRIGHT}
        else
            corner = {BORDERTOPLEFT, BORDERTOPRIGHT}
        end

        table.insert(lines, corner[1] .. roof .. corner[2])
    end

    local function fillhalf(half_type)
        local callstack = {
            function()
                get_roof(half_type)
            end
        }
        if half_type == "bottom" then
            -- divide by two preventing disproportional
            callstack[2] = make_insert_vpadding(hori_padding[2] / 2, true)
            Reverse(callstack)
        else
            callstack[2] = make_insert_vpadding(hori_padding[1] / 2, true)
        end

        for _, call in pairs(callstack) do
            call()
        end
    end

    local transform_content = function(fn)
        for _, con in pairs(contents) do
            table.insert(lines, fn(con, vert_padding))
        end
    end

    local callstack
    -- config["border"] = true
    if config["border"] then
        callstack = build_add_border(add_border_each_line, fillhalf)(lines, property)
    else
        local hpl = make_insert_vpadding(hori_padding[1], false)
        local hpr = make_insert_vpadding(hori_padding[2], false)
        callstack = {hpl, store(transform_content, apply_padding), hpr}
    end

    for _, call in pairs(callstack) do
        call()
    end

    local res = {
        property = property,
        lines = lines
    }

    return res
end

local common = access_core("colorscheme").gruvbox
local function create_hiname(color)
    local hlname = RandomString(5)
    color = common[color] or color

    local hlcmd = "hi " .. hlname .. " guifg=" .. color
    vim.cmd(hlcmd)
    return hlname
end

-- It will interpreted "\\" as new line
-- two config will translate into method
local text_builder = function(texts)
    local tobj = {}
    local border_conf = {
        has_color = false,
        color = nil,
        hlname = nil
    }
    local config = {
        border = false,
        padding = {1, 1}
    }

    tobj.border = function(color)
        config["border"] = true
        if color then
            border_conf["color"] = color
            border_conf["has_color"] = true
            border_conf["hlname"] = create_hiname(color)
        end

        return tobj
    end

    tobj.padding = function(pad)
        assert(pad ~= nil, "Cannot input nil value into padding")
        config["padding"] = pad
        return tobj
    end

    tobj.build = function()
        -- inject border function !!
        local new = create_text_obj(texts, config)
        new["border_config"] = border_conf

        return new
    end

    return tobj
end

function MakeHighlighBorder(txt_obj, color)
    local api = vim.api
    local hlname = create_hiname(color)

    return function(bufnr)
        for i, txt in pairs(txt_obj["lines"]) do
            local max_len = #txt
            local skip_len = 2
            api.nvim_buf_add_highlight(bufnr, -1, hlname, i - 1, skip_len, 3)

            if i == 1 or i == #txt_obj["lines"] then
                api.nvim_buf_add_highlight(bufnr, -1, hlname, i - 1, skip_len, max_len)
            else
                api.nvim_buf_add_highlight(bufnr, -1, hlname, i - 1, max_len - skip_len, max_len)
            end
        end
    end
end

-- create builder methods :
-- padding([lr,ud...]) :
-- border() : bool
return text_builder
