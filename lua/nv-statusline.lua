local utils = require("utility")

local cols = {
    orange = "#d65d0e",
    white = "#ffffff",
    cyan = "#008080",
    red = "#ec5f67",
    nord = "#458588",
    darkblue = "#427b58",
    black = "#3c3836",
    dark_yellow = "#b57614",
    green = "#98971a",
    light_purple = "#8f3f71",
    lightgold = "#ebdbb2"
}

cols.bg = cols.lightgold
-- schemas :
-- hi = {
--     background =
--     forground = ,
-- }
--
-- sep = {
--     text = "",
--     highlight = hi
--
-- }
--

local function nest(k, v)
    local arr = {}
    arr[k] = v
    return arr
end

local function hischema(hi)
    local fg = hi.fg or hi.forground
    local bg = hi.bg or hi.background
    return {fg, bg}
end

local function make_gls_text(text)
    return function(hi, sep, sephl)
        local shl = {}
        if sephl ~= nil then
            shl = hischema(sephl)
        end
        return {
            provider = function()
                return text
            end,
            highlight = hischema(hi),
            seperator = sep or " ",
            -- seperator_highlight =
            seperator_highlight = {cols.bg, cols.bg}
        }
    end
end

local function glsrr(col)
    local fn = make_gls_text("")
    local input = col

    if type(col) ~= "table" then
        input = {bg = "None", fg = col}
    end
    return fn(input)
end

local function glslr(col)
    local fn = make_gls_text("")
    local input = col

    if type(col) ~= "table" then
        input = {bg = "None", fg = col}
    end

    return fn(input)
end

local couple = "couple"
BaseCount = 0

-- make it a pill shape component
-- each component require to has unique name otherwise
-- it gls will render the same component dispise having diff
-- name;
-- comp = component
-- We could build generic function to make half half_pill_shape

local function transmute_shape(uniq, blocks)
    local comp_arr = {}
    local l = #blocks
    for i, block in pairs(blocks) do
        local u = nil
        if i == l then
            u = uniq .. "glr"
        end

        if i == 1 then
            u = uniq .. "glr"
        else
            u = uniq .. i
        end

        comp_arr[i] = nest(u, block)
    end
    return comp_arr
    -- this is mapper functions
end

local function get_corner_hl(inner, round_bg)
    local h = inner["highlight"][2]
    if round_bg ~= nil then
        h = {fg = h, bg = round_bg}
    end
    return h
end

local function pill_shape_comp(uniq, inner, round_bg)
    local h = get_corner_hl(inner, round_bg)
    local blocks = {glslr(h), inner, glsrr(h)}
    local c = transmute_shape(uniq, blocks)
    return nest(couple, c)
end

local function bullet_shape(dir, uniq, inner, round_bg)
    local h = get_corner_hl(inner, round_bg)
    local blocks = {inner}

    if dir == "left" or dir == nil then
        blocks[1] = glslr(h)
        blocks[2] = inner
    end

    if dir == "right" then
        blocks[2] = glsrr(h)
    end

    -- inner ,glsrr(h)
    return nest(couple, transmute_shape(uniq, blocks))
end

local galaxyline = require("galaxyline")
local fileinfo = require("galaxyline.provider_fileinfo")

local vcs = require("galaxyline.provider_vcs")
local gls = galaxyline.section

local function make_gls_sections(pos, sections)
    local j = 0
    for i, section in pairs(sections) do
        if section["couple"] ~= nil then
            for _, subsection in pairs(section["couple"]) do
                gls[pos][i + j] = subsection
                j = j + 1
            end
        else
            if j ~= 0 then
                i = i + j
            end
            gls[pos][i] = section
        end
    end
end

local function build_git_header()
    -- workspace , gitbranch include in git module
    local ws = require("galaxyline.provider_vcs").check_git_workspace
    local hl = nil
    local txt = ""

    local gitbranch = vcs.get_git_branch()
    if ws ~= nil or gitbranch ~= nil then
        hl = {bg = cols.black, fg = cols.white}
        local g = string.format("%s ", gitbranch)
        txt = " " .. g
    else
        hl = {bg = cols.white, fg = cols.red}
        txt = " Empty "
    end

    local git_header = {
        provider = function()
            return txt
        end,
        highlight = hischema(hl)
        -- separator = "??/",
    }

    return git_header
end

GitHeader = build_git_header()
-- local function make_short_list()

FileSize = {
    provider = function()
        local fz = fileinfo.get_file_size()
        if fz == "" then
            return "New !"
        end
        return fz
    end,
    icon = " ",
    highlight = {cols.white, cols.orange}
}

Fs = nest("FileSize", FileSize)

Default = {
    hi = {
        background = cols.orange,
        forground = cols.nord
    }
}

-- Background = nest("bg",f(config.hi))
Background =
    nest(
    "bg",
    {
        provider = function()
            return "Ohno"
        end,
        highlight = {cols.bg, cols.bg},
        seperator = "??",
        seperator_highlight = {cols.bg, cols.bg}
    }
)

-- to ensure the name of each padding is unique
-- not cause overlap bug
local uniq_padding_count = 0
local padding = function(pad, bg)
    if bg == nil then
        bg = cols.bg
    end
    uniq_padding_count = uniq_padding_count + 1
    return nest(
        uniq_padding_count .. "pad",
        {
            provider = function()
                return string.rep(" ", pad)
            end,
            highlight = {bg, bg},
            seperator = " ",
            seperator_highlight = {bg, bg}
        }
    )
end

local default_alias = {
    n = "NORMAL",
    i = "INSERT",
    c = "COMMAND",
    V = "VISUAL",
    [""] = "VISUAL",
    v = "VISUAL",
    R = "REPLACE"
}
local function build_vimode_indicator(hi, alias)
    ViMode = {
        provider = function()
            if alias == nil then
                alias = default_alias
            end
            --vim.fn.mode() -> abbreviation
            --such as 'n' for 'normal'
            return alias[vim.fn.mode()]
        end,
        highlight = hischema(hi),
        seperator = ""
    }
    return ViMode
end

local condition = require("galaxyline.condition")

local function build_filename_component(hi)
    local h = hischema(hi)
    -- print("testst",h[1],h[2],hi.bg)
    return {
        provider = function()
            local fileIcon = fileinfo.get_file_icon()
            local fileName = fileinfo.get_current_file_name()
            return "  f:" .. fileIcon .. AllTrim(fileName) .. " "
        end,
        condition = condition.buffer_not_empty,
        highlight = h
    }
end

local function get_key_set(tab)
    local keyset = {}
    local n = 0

    for k, _ in pairs(tab) do
        n = n + 1
        keyset[n] = k
    end
    return keyset
end

-- require individual component to be nested
local function link_component(dir, comps, spacing)
    local linked = {}
    local s = spacing or 0

    local function get_bg_col(c)
        local k = get_key_set(c)[1]
        if type(k) ~= "string" then
            error("Suspected array! Require nested table to work", 2)
        end
        if c ~= nil then
            return c[k]["highlight"][2]
        end
    end

    linked[1] = padding(s, get_bg_col(comps[1]))
    local u = 2

    for i, comp in pairs(comps) do
        local k = get_key_set(comp)[1]
        local corner_bg = nil
        local n = comps[i + 1]
        if comps[i][k] == nil then
            print("Detect empty header!")
            return
        end
        if n ~= nil then
            corner_bg = get_bg_col(n)
        end

        linked[u] = bullet_shape(dir, k, comp[k], corner_bg)
        linked[u + 1] = padding(s, corner_bg)

        -- -- for debugging
        -- local key = get_key_set(linked[u+1])[1]
        -- print("padding-key:",key,corner_bg)
        -- print("====>uuu",u,u+1,i)
        --
        u = u + 2
    end
    -- !important
    if dir == "left" then
        Reverse(linked)
    end
    return linked
end

local txt_percentage =
    nest(
    "TextPercentage",
    {
        provider = function()
            local linePercent = fileinfo.current_line_percent()
            local lineColumn = fileinfo.line_column()

            return " " .. linePercent .. "|" .. lineColumn
        end,
        highlight = hischema(
            {
                bg = cols.darkblue,
                fg = cols.white
            }
        )
    }
)

local unix =
    nest(
    "Unix",
    make_gls_text("Unix  ")(
        {
            bg = cols.white,
            fg = cols.black
        }
    )
)
local leftlinked =
    link_component(
    "right",
    {
        nest(
            "filename",
            build_filename_component(
                {
                    bg = cols.nord,
                    fg = cols.white
                }
            )
        ),
        nest("FileSize", FileSize),
        unix
    },
    1
)

-- freebsd logo: 
local freebsd =
    nest(
    "freebsd",
    make_gls_text("")(
        {
            fg = cols.light_purple,
            bg = cols.white
        }
    )
)

--pill_shape_comp({linecol})

local rightlinked =
    link_component(
    "left",
    {
        freebsd,
        nest(
            "ViMode",
            build_vimode_indicator(
                {
                    bg = cols.red,
                    fg = cols.white
                }
            )
        ),
        nest("GitIcon", GitHeader),
        txt_percentage
    },
    2
)
-- make_gls_sections("mid",rightlinked)

--make_gls_sections("right",mlinks)

-- sec
galaxyline.short_line_list = {
    "LuaTree",
    "NvimTree",
    "vista",
    "dbui",
    "startify",
    "term",
    "dashboard",
    "Trouble",
    "qf",
    "toggleterm",
    "nerdtree"
}

local file_type = {
    provider = "FileTypeName",
    highlight = {cols.white, cols.darkblue}
}

--FileTypeName
make_gls_sections(
    "short_line_left",
    {
        -- pill_shape_comp("BufferIcon",unix["Unix"])
        padding(2, cols.red),
        nest(
            "Bruh",
            make_gls_text("  ")(
                {
                    bg = cols.red,
                    fg = cols.white
                }
            )
        )
    }
)

make_gls_sections("short_line_mid", {})
make_gls_sections(
    "short_line_right",
    {
        pill_shape_comp("Ftype", file_type, cols.red),
        padding(2, cols.red)
    }
)

make_gls_sections("left", leftlinked)
make_gls_sections("right", rightlinked)

-- vim.cmd("hi statusline guibg=#111111")
