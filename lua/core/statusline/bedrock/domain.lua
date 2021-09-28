_G.LINKED = "COUPLE"
G = {}
HEX_COLOR_LENGTH = 7
local function hi_schema(f, b)
    HLSCHEMA = {
        background = nil,
        foreground = nil
    }

    HLSCHEMA["background"] = b
    HLSCHEMA["foreground"] = f
    return HLSCHEMA
end

local function from_hlschema(schema)
    if schema == nil then
        return
    end
    local f = schema.foreground or schema.fg or "NONE"
    local b = schema.background or schema.bg or "NONE"
    --    print("[[[[[[[  ]]]]]]]", h, f)
    -- check_color()
    local res = {f, b}
    -- Reverse(res)
    --print("Foreground", res[1], res[2])
    return res
end

-- the function control the schema
-- it will not fail if we forgot to give hl or sep

local function make_component(p, hl, sep)
    COMPONENTSCHEMA = {
        provider = nil,
        highlight = nil,
        seperator = nil
    }
    local inp = nil
    if type(p) == "string" then
        inp = function()
            return "" .. p
        end
    else
        inp = p
    end
    assert(type(inp) == "function")
    -- print("FUNCKING PROVIDERRRRRR ===> after", inp)
    -- print("RES", inp())

    local fallback = {"NONE", "NONE"}
    -- nested schema
    COMPONENTSCHEMA["provider"] = inp
    -- highlight is according to schema
    if type(hl) == "function" then
        COMPONENTSCHEMA["highlight"] = hl
    else
        COMPONENTSCHEMA["highlight"] = from_hlschema(hl) or fallback
    end
    COMPONENTSCHEMA["seperator"] = sep or fallback

    return COMPONENTSCHEMA
end

-- example
-- local sayhello =
--     make_component(
--     "hello",
--     {
--         fg = "red",
--         bg = "blue"
--     }
-- )

-- Boundary : colorscheme must contain :
-- primary:background,foreground
-- rgb : red,green,blue
-- white and black
-- each color must be hex value no longer than len(6)
local function isHexValue(color)
    assert(type(color) == "string")
    local start = string.sub(color, 1, 1)
    return #color == HEX_COLOR_LENGTH and start == "#"
end

local function make_checker(isHexValue)
    return function(col_object, COLORSCHEMA)
        for colname, _ in pairs(COLORSCHEMA) do
            -- print(colname, col_object[colname])
            local colorspec = col_object[colname]

            if colorspec == nil then
                local errmsg = "Failed to initialize colorscheme!" .. "\nrequire " .. colname
                error(errmsg, 2)
            end

            -- if #colorspec > HEX_COLOR_LENGTH then
            --     error("Invalid color!")
            -- end

            if not isHexValue(colorspec) then
                error("Invalid color!")
            end

            -- remove that object
            -- col_object[colname] = nil
            COLORSCHEMA[colname] = colorspec
        end
    end
end

local function make_colorscheme(col_object)
    COLORSCHEMA = {
        red = "",
        white = "",
        black = "",
        foreground = "",
        background = ""
    }

    local check_essential_color = make_checker(isHexValue)
    check_essential_color(col_object, COLORSCHEMA)

    -- extending colorscheme
    for i, col in pairs(col_object) do
        COLORSCHEMA[i] = col
    end
    return COLORSCHEMA
end

G.check_color = function(col, colorscheme)
    if colorscheme[col] == nil or col == nil then
        print(debug.traceback("Track color " .. col))
        error("This colorscheme does not support color [[" .. col .. "]]", 2)
    else
        return colorscheme[col]
    end
end

G.from_highlight = from_hlschema
G.make_highlight = hi_schema
G.make_component = make_component
G.make_colorscheme = make_colorscheme

G.is_hex = isHexValue

return G
