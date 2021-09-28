local import = make_import(BEDROCK_ROOT)

local o, u = import("usecases.renderer"), import("usecases.ui")
local r_port, rblueprint = o[1], o[2]
local u_port, u_blueprint = u[1], u[2]

local l = import("drivers.lib")
print("DAIGN")
local d = import("drivers.diagnostics")

local uniq, nest = l.uniq, l.nest
-- local vcs, nvim, file = dta.vcs, dta.nvim, dta.file

BUILD_IMPL(rblueprint)
BUILD_IMPL(u_blueprint)

-- things require nest,cuz of linker

function Requirement(bp)
    bp.uniq = bp.uniq:build(uniq)
    bp.nest = bp.nester:build({nest = nest}).nest
    bp.linker = "COUPLE"
end

Requirement(rblueprint)
Requirement(u_blueprint)

USECASE = {}

-- example-RENDER : init({
-- colorscheme = cols,
-- render_engine = renderer,
-- })

-- example-UI : init({
-- colorscheme = cols,
-- repo = data-access,
-- })

USECASE.renderer = function(A)
    assert(A["colorscheme"] ~= nil, "require colorscheme")
    assert(A["render"] ~= nil, "require render logic!")

    local cols, renderer = A["colorscheme"], A["render"]
    local common = {renderer, cols}

    local rbuilt =
        rblueprint.inject(
        {
            make_padding = common,
            make_bullet_shape = common,
            make_text = {cols},
            build_make_corner = common,
            make_component_linker = {renderer},
            make_pill_shape = {renderer}
        }
    )

    return r_port.build(rbuilt, true)
end

USECASE.provider = function(A)
    assert(A["colorscheme"] ~= nil, "require colorscheme")
    assert(A["repository"] ~= nil, "require repository logic!")
    assert(A["formatters"] ~= nil, "require formatters logic!")

    local cols = A["colorscheme"]
    local dta = A["repository"]

    local vcs, nvim, file = dta.vcs, dta.nvim, dta.file
    u_blueprint.formatters = A["formatters"]

    local ubuilt =
        u_blueprint.inject(
        {
            build_vcs_icon = {vcs, cols},
            build_line_position = {nvim, cols},
            build_page_position = {nvim, cols},
            build_vimode_indicator = {nvim, cols},
            build_filesize = {file, cols},
            build_filename = {file, cols},
            build_diagnostic = {d, cols}
        }
    )
    return u_port.build(ubuilt, false)
end

return USECASE
