local uc = import("usecases.init", BEDROCK_ROOT)
local h = import("containers.helper")
local InContainer, stamp, InBedrock = h.InContainer, h.stamp, h.InBedrock

local rc = InContainer("rc")
local colorscheme = rc.colorscheme

local ui_lib = InContainer("ui.feline")
local make_linker_binder = InContainer("components.factory.link-highlight")

local init = InContainer("components.initialization")
local modehl = InContainer("components.modehl")
local a = InContainer("components.filesizehl").init(colorscheme, ui_lib)

local empty_size_config = a.filesizehl

local render_driver = InBedrock("drivers.renderer")
local repo = InBedrock("data-access.init")

local rend =
    uc.renderer(
    {
        colorscheme = colorscheme,
        render = render_driver
    }
)

local ctl = InContainer("presenter.init")

local presenter = ctl[2]

local bgstash = init.initstash()

-- local dynhl = ui_lib.capabilities["DynHL"]:init()
local empty_file = empty_size_config(bgstash.init("filesize_bg"))

presenter.UILib = ui_lib
MData = nil
local ui =
    uc.provider(
    {
        colorscheme = colorscheme,
        repository = repo,
        -- Important : formatter could be use if the data-access does not rely on
        -- any ui providers
        formatters = {
            filesize = function(data)
                empty_file.get(data)
                local res = string.format("%s%s", data, " ")
                return res
            end,
            vcs = function(branch)
                if branch == "" then
                    return string.format("NoRepo %s", "")
                else
                    return string.format("%s %s", "", branch)
                end
            end,
            filename = function(fn)
                if #fn == 2 then
                    return "Empty file"
                end
                return fn
            end,
            page_position = function(data)
                local unit = "%%"
                return string.format("%s%s %s", unit, data, " ")
            end,
            line_position = function(data)
                return string.format("%s %s", "", data)
            end,
            vimode = function(data)
                if data ~= MData then
                    MData = data
                end
                return string.format("%s %s", "m: ", data)
            end
        }
    }
)

local gls = init.StatusLine:init(presenter, {"left", "right", "mid"})
-- left_view : lv
-- right_view : rv
-- mid_view : mv

local git =
    ui.vcs_icon(
    {
        fg = "white",
        bg = "black"
    }
)

local filename =
    ui.filename(
    {
        fg = "white",
        bg = "orange"
    }
)

local line =
    ui.line_position(
    {
        fg = "white",
        bg = "green"
    }
)

local page_pos =
    ui.page_position(
    {
        fg = "white",
        bg = "light_purple"
    }
)

local filesize =
    ui.filesize(
    {
        fg = "white",
        bg = "darkblue"
    }
)

-- OS WITH HOLO EFFECT
local ani = InContainer("components.factory.animations").init(ui_lib, colorscheme)
local holo = {
    fg = ani.holo_fade("fg"),
    bg = ani.holo_fade("bg")
}

local unix = rend.pill_shape(rend.text(" " .. rc.os, {fg = "black", bg = "white"}), "ROUND", {"black"})

local function l(c, bindfn)
    local ip = c[LINKED] or c
    for i, comp in pairs(ip) do
        local cp = stamp(comp)
        if c[LINKED] == nil then
            cp = comp
        end
        -- core got bg highlighting
        if i == 2 then
            bindfn(cp, holo["bg"])
        else
            bindfn(cp, holo["fg"])
        end
    end
end

l(unix, ui_lib.bind)
--ui_lib.bind(unix, hlrange)
-- change highlighting and icon
-- dyn_component()
local mode =
    ui.vimode_indicator(
    {
        fg = "white",
        bg = "red"
    }
)

local function link_fn(comp, dir, colorbg)
    _ = nil
    -- request for next bg color
    if comp == _ and dir == _ then
        return {bg = colorscheme["black"]}
    end

    local x = rend.bullet_shape(comp, dir, "ROUND", colorbg)

    return x
end

--- bind
local diags = ui.diagnostic("black", rc.diagnostic)

-- l(diags, ui_lib.bind)

-- COMPONENTS LOCATION GOES HERE!
-- pls fix mirroring issue !
-- fixed : by moving left_link code to the bottom and right_link to top

-- local pls = rend.pill_shape(mode, "ROUND", {n["light_purple"], n["background"]})

-- -- fixed this please

-- ## RIGHTLINK CONFIGURATION !!!
local right_link = rend.component_linker({mode, page_pos, line}, 1, "left", link_fn)

local linkerbind = make_linker_binder(2, ui_lib.bind)

bgstash.setbg("modehl_bg", colorscheme["light_purple"])
linkerbind(right_link, 4, modehl.config(ui_lib, colorscheme, bgstash.init("modehl_bg")))

gls.right({unpack(right_link)})
-- ## RIGHTLINK END

-- ## LEFTLINK CONFIGURATION !!!
-- IMPORTANT ! : must put right_link first to avoid bug
local left_link = rend.component_linker({filename, filesize, git}, 1, "right", link_fn)

gls.left({unpack(left_link)})
gls.left(unix)
gls.left(
    {
        rend.text(
            " ",
            {
                bg = "black",
                fg = "white"
            }
        )
    }
)

gls.left(diags)

Reverse(left_link)
bgstash.setbg("filesize_bg", "black")
linkerbind(left_link, 3, empty_file.config, "left")
Reverse(left_link)

-- ## LEFTLINK END
gls:endhook(ui_lib.init):run()
