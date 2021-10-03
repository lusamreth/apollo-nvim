-- new rules every output of usecases must include name
-- require uniq module

RENDER_USECASE = {}
RENDER_USECASE.nester = nil
RENDER_USECASE.LINKER = ""

local helper = import("bedrock.usecases.helpers")
local identifier = helper.identifier

RENDER_USECASE.nester = identifier.Nester:init(UI_USECASE)
RENDER_USECASE.nest = identifier.Nester:init(RENDER_USECASE).nest
RENDER_USECASE.uniq = identifier.Identifier:init(RENDER_USECASE)

local default_color_check = helper.default_color_check

local nest = function(n, c)
    return RENDER_USECASE.nest(n, c)
end
-- please set linker for these components
assert(RENDER_USECASE.linker ~= "", "linker is not yet set!")
SCHEMA = import("bedrock.domain")

-- error of the problem laid here!
RETURN_COMP = unpack({"->", "table"})
RETURN_NESTED_COMP = unpack({"->", "table"})

local ifc = {
    -- spaces,"color"
    {"padding", {{"number", "string"}, "->", "table"}},
    -- text,highlight,seperator
    {"text", {{"string", "table", "table"}, "->", "table"}},
    {"make_corner", {{"table", "string", "string"}, "->", "table"}},
    -- whole component,direction,link_shape, corner_background(seemless link)
    {"bullet_shape", {{"table", "string", "string", "string"}, "->", "table"}},
    -- components , padding, direction , linker_fn
    {"component_linker", {{"table", "number", "string", "function"}, "->", "table"}},
    -- components <arr>, corner_shape, corner_bg<just string>
    {"pill_shape", {{"table", "string", "table"}, "->", "table"}}
}

local link_fn_interface =
    interface.build_interface(
    {
        {
            "link_fn",
            -- this function will take care of link shape
            -- this function will also take highligh
            -- inner_component,"dir",corner_shape
            {{"table", "string", "string"}, "->", "table"}
        },
        -- use for post processing linking 2 comps;
        -- the name uses in nested linker must be later interpreted
        -- by library and the detial of mergin these comps lives in
        -- those dependencies
        {"links", {"table", "->", "table"}}
    }
)

RENDERER_PORT = interface.build_interface(ifc)

-- Renderer usecase implementation
RENDER_USECASE.make_padding = function(render, colorscheme)
    return function(spaces, col)
        SCHEMA.check_color(col, SCHEMA.make_colorscheme(colorscheme))
        local p = render.create_padding(spaces)
        local pid = RENDER_USECASE.uniq.get_id("padding")
        if not SCHEMA.is_hex(col) then
            col = colorscheme[col]
        end
        return nest(pid, SCHEMA.make_component(p, {bg = col}))
    end
end

RENDER_USECASE.make_text = function(cols)
    return function(text, hi, sp)
        local id = RENDER_USECASE.uniq.get_id("txt")
        local h = default_color_check(hi, cols)
        -- print("text id ", id)
        return nest(
            id,
            SCHEMA.make_component(
                function()
                    return text
                end,
                h,
                sp
            )
        )
    end
end

-- rtype = {"round",dir}
RENDER_USECASE.build_make_corner = function(render, colorscheme)
    return function(rtype, fg, bg)
        local r = render.make_corner(rtype)
        local hl = default_color_check(SCHEMA.make_highlight(fg, bg), colorscheme)
        local id = RENDER_USECASE.uniq.get_id("corner")
        return nest(id, SCHEMA.make_component(r, hl))
    end
end

local function link(comp_arr)
    return nest(RENDER_USECASE.linker, comp_arr)
end

-- TODO:pls fix this shit !
-- vector contain (uniq,direction,blocks)
RENDER_USECASE.make_bullet_shape = function(render, colorscheme)
    return function(comp, dir, link_shape, corner_bg)
        local bls = render.bullet_shape(dir, link_shape)
        local comps = {}
        local head, pos = bls["head"], bls["pos"]
        -- print("TTT", tail, pos["tail"], head, pos["head"], dir, corner_bg)

        -- local hi_arr = SCHEMA.from_highlight(hi)
        -- if not SCHEMA.is_hex(hi_arr[1]) then
        --     hi = default_color_check(SCHEMA.make_highlight(unpack(hi_arr)), colorscheme)
        -- end

        local hi = SCHEMA.make_highlight(unpack(comp["highlight"]))
        assert(comp["provider"] ~= nil)

        comps[pos["tail"]] = comp
        comps[pos["head"]] = SCHEMA.make_component(head, {fg = hi["background"], bg = corner_bg})
        return link(comps)
    end
end

-- linker must be supported by render
-- components through this linker must be nested
-- with name !

local function get_bg_col(component)
    if #component > 0 then
        -- a nested component contains array value
        error("Each Component Must not be nested")
    end
    if component ~= nil then
        local hl = SCHEMA.make_highlight(unpack(component["highlight"]))
        return hl["background"]
    end
end

local function make_link_padding(render, s)
    return function(col)
        local name = RENDER_USECASE.uniq.get_id("padding_link")
        local p = render.create_padding(s)
        local comp_p = SCHEMA.make_component(p, SCHEMA.make_highlight(nil, col))
        return nest(name, comp_p)
    end
end

local function unest(nested)
    local k = RENDER_USECASE.uniq.get_key(nested)
    return nested[k]
end

local function unest_iter(nested_comps)
    local unested = {}
    for i, c in pairs(nested_comps) do
        unested[i] = unest(c)
    end
    return unested
end

RENDER_USECASE.make_component_linker = function(render)
    return function(comps, spacing, dir, link_fn)
        local linked = {}
        -- must respect spec of linker
        link_fn = link_fn_interface.build({link_fn = link_fn}).link_fn
        local s = spacing or 2
        local link_padding = make_link_padding(render, s)

        local initial = unest(comps[1])
        linked[1] = link_padding(get_bg_col(initial))
        local u = 2

        local unested = unest_iter(comps)

        for i, c in pairs(unested) do
            assert(c ~= nil)
            local corner_bg = nil
            local n = unested[i + 1]
            if c == nil then
                error("Detect empty header!")
                return
            end
            if n ~= nil then
                corner_bg = get_bg_col(n)
            end

            -- input requires : <ALSO CONTAIN HIGHLIGHT>,dir<STRING>
            -- linked[u] = link_fn(c[k]["provider"], dir,hl,cbg)

            if corner_bg == nil then
                corner_bg = "#ffffff"
                _ = nil

                -- function overload!! if support should return bg col
                local support, res = pcall(link_fn, _, _, "bg")
                if support == true then
                    corner_bg = res["bg"]
                end
            end
            linked[u] = link_fn(c, dir, corner_bg)
            linked[u + 1] = link_padding(corner_bg)

            u = u + 2
        end

        if dir == "left" then
            Reverse(linked)
        end

        return linked
    end
end

RENDER_USECASE.make_pill_shape = function(render, colorscheme)
    local corn_id = function()
        return RENDER_USECASE.uniq.get_id("pill_shape_corner")
    end

    return function(nested, corner_shape, corner_bg)
        local left_corn = render.make_corner({corner_shape, "left"})
        local c = unest(nested)
        local right_corn = render.make_corner({corner_shape, "right"})
        -- corner_bg
        local comp_hl = SCHEMA.make_highlight(unpack(c["highlight"]))

        local corn_hls = {}

        for i, cbg in pairs(corner_bg) do
            if not SCHEMA.is_hex(cbg) then
                cbg = colorscheme[cbg]
            end
            local corn_hl = {}
            corn_hl["foreground"] = comp_hl.background
            corn_hl["background"] = cbg
            corn_hls[i] = corn_hl
        end

        local corns = {}
        for i, corn in pairs({left_corn, right_corn}) do
            if i == 1 then
                local n = nest(corn_id(), SCHEMA.make_component(corn, corn_hls[1]))
                corns[i] = n
            else
                local n = nest(corn_id(), SCHEMA.make_component(corn, corn_hls[2] or corn_hls[1]))
                corns[i] = n
            end
        end

        return {corns[1], nested, corns[2]}
    end
end

return {RENDERER_PORT, RENDER_USECASE}
