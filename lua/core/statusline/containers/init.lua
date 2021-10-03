-- !IMPORTANT: All highlighting and effects need to be import and apply here for the
-- effect to work correctly

import("containers.components.init")

local h = import("containers.helper")
local InContainer = h.InContainer

local init = InContainer("components.initialization")
local ctl = InContainer("presenter.init")

local presenter = ctl[2]

local ui_lib = InContainer("ui.feline")

local function make_bar(kind)
    if ui_lib["build_drawer"] then
        ui_lib.build_drawer(kind)
    end

    presenter.UILib = ui_lib

    return init.StatusLine:init(presenter, {"left", "right", "mid"})
end

Binder = ui_lib.bind
local active_bar = make_bar("active")

OSHOLO = HoloPillshape(OsPillShape, ui_lib.bind)

-- ## RIGHTLINK CONFIGURATION !!!
active_bar.right({unpack(MakeCommonRL(ui_lib))})
-- ## RIGHTLINK END
--
-- ## LEFTLINK CONFIGURATION !!!
active_bar.left({unpack(MakeCommonLL(ui_lib))})
-- last end
active_bar.left(OSHOLO)
active_bar.left({SpacingText})
active_bar.left(Diagnostics)
-- ## LEFTLINK CONFIGURATION !!!

-- starting statusline

active_bar:endhook(ui_lib.init):run()

-- inactive bar configs
local inactive_bar = make_bar("inactive")

inactive_bar.left(OsLink)
inactive_bar.left({SpacingText})
inactive_bar.right({Pad(1)})
inactive_bar.right(BSDSymbol)
inactive_bar.right({Pad(1)})

inactive_bar:run()
