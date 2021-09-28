-- mock use for testing
local uc = import("usecases.init")
local n = import("colorscheme")

local render_driver = import("drivers.renderer")
local rend =
    uc.renderer(
    {
        colorscheme = n,
        render = render_driver
    }
)

local repo = import("data-access.init")
local ctl = import("controllers.presenter")
local ui =
    uc.provider(
    {
        colorscheme = n,
        repository = repo
    }
)

local presenter = ctl[2]

local ui_uc = import("drivers.galaxyline")
presenter.UILib = ui_uc
-- local bind_to_view =

MOCK_HL = {
    foreground = "red",
    background = "darkblue"
}

local p = rend.padding(10, MOCK_HL["background"])
local c = rend.bullet_shape("This is bullet_shape", "right", "ROUND", MOCK_HL, "darkblue")
local x = rend.text("Ok this is cool!", MOCK_HL, {})
local x2 = rend.text("Ok this is cool! number 2", {fg = "white", bg = "green"}, {})

local git =
    ui.vcs_icon(
    {
        fg = "white",
        bg = "black"
    }
)

local mocklinkfn = function(text, dir, hl, b)
    return rend.bullet_shape(text, dir, "HEXARROW", hl, b)
end

-- presenter[2].bind_to_view({p, x, x2}, "left", ui_uc)
-- presenter[2].bind_to_view(x2, "left", ui_uc)
--ui_uc.draw({p, x}, "left")

local left_view = presenter.make_view_binder(ui_uc, "left")
local right_view = presenter.make_view_binder(ui_uc, "right")
local mid_view = presenter.make_view_binder(ui_uc, "mid")
mid_view(x2)
local function pill_shape_comp(comp, hl, cbg)
    local rc1 = rend.make_corner({"ROUND", "left"}, hl["fg"], cbg)
    local rc2 = rend.make_corner({"ROUND", "right"}, hl["fg"], cbg)

    mid_view(rc1)
    mid_view(comp)
    mid_view(rc2)
end

local filename =
    ui.filename(
    {
        fg = "red",
        bg = "darkblue"
    }
)

local o = rend.pill_shape(x, "ROUND", "white")
local o2 = rend.pill_shape(git, "ROUND", "red")
-- text, dir, link_shape, hi, corner_bg
local o3 = rend.bullet_shape("bruh", "left", "ROUND", {fg = "red", bg = "green"}, "white")

-- bullet_shape is a couple component
local bundle = {x, filename}
local function lfn2(txt, dir, hl, cb)
    return rend.bullet_shape(txt, "di", "ROUND", hl, cb)
end
local linked_comp_right = rend.component_linker(bundle, 2, "left", mocklinkfn)

for _, a in pairs(linked_comp_right) do
    right_view(a)
end

local linked_comp_left = rend.component_linker({git, x}, 2, "right", mocklinkfn)

for _, a in pairs(linked_comp_left) do
    left_view(a)
end
right_view(o3)

local hl = {
    fg = "nord",
    bg = "white"
}

-- ui_uc.init()
-- print("Already init")
