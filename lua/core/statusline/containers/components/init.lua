Comp = {}
local uc = import('usecases.init', BEDROCK_ROOT)
local h = import('containers.helper')
local InContainer, stamp, InBedrock = h.InContainer, h.stamp, h.InBedrock

local rc = import('rc')
local colorscheme = rc.colorscheme

local ui_lib = InContainer('ui.feline')
local make_linker_binder = InContainer('components.factory.link-highlight')

local init = InContainer('components.initialization')
local modehl = InContainer('components.modehl').config(colorscheme, rc['mode'])
local a = InContainer('components.filesizehl').init(colorscheme, ui_lib)

local empty_size_config = a.filesizehl

local render_driver = InBedrock('drivers.renderer')
local bd_helper = InBedrock('drivers.lib')
local repo = InBedrock('data-access.init')

local rend = uc.renderer({
    colorscheme = colorscheme,
    render = render_driver,
})

local bgstash = init.initstash()

-- basic cache
Cache = {}
local function lookup(key, func, data)
    if Cache[key] == nil then
        Cache[key] = {
            data = nil,
            computed = nil,
            already_computed = {},
        }
    end
    local tar = Cache[key]
    if tar['data'] ~= data then
        local inner_cache = tar.already_computed[data]
        tar['data'] = data

        -- signifcantly reduce function call ~
        if inner_cache ~= nil then
            tar['computed'] = func(data)
        else
            tar['computed'] = func(data)
            tar.already_computed[data] = tar['computed']
        end

        -- for debug
    end
    return tar['computed']
end

local gl_emptyfile = function(fn)
    return #fn == 5
end

local empty_file = empty_size_config(bgstash.init('filesize_bg'))
local interceptors = {
    filesize = function(data)
        lookup('filesize', empty_file.get, data)
        local res = string.format('%s%s', data, ' ')
        return res
    end,
    vcs = function(branch)
        if branch == '' then
            return string.format('NoRepo %s', '')
        else
            return string.format('%s %s', '', branch)
        end
    end,
    filename = function(fn)
        if gl_emptyfile(fn) then
            return ' '
        end
        return AllTrim(fn) .. ' '
    end,
    page_position = function(data)
        local icon = ''
        local t = AllTrim(data)
        if t == 'Top' then
            icon = ''
        elseif t == 'Bot' then
            icon = ''
        end
        local unit = '%%'
        return string.format(' %s%s %s', unit, data, icon)
    end,
    line_position = function(data)
        return string.format(' %s%s', '線 ', AllTrim(data))
    end,
    vimode = function(data)
        local icon = lookup('icon_mode', modehl.getmodeicon, data)
        return string.format(' %s %s ', icon, data)
    end,
}

local ui = uc.provider({
    colorscheme = colorscheme,
    repository = repo,
    -- Important : formatter could be used if the data-access does not rely on
    -- any ui providers
    -- those functions will be called frequently so be cautious
    formatters = interceptors,
})

Vcs = ui.vcs_icon({
    fg = 'white',
    bg = 'black',
})

Filename = ui.filename({
    fg = 'white',
    bg = 'orange',
})

LinePos = ui.line_position({
    fg = 'white',
    bg = 'nord',
})

PagePos = ui.page_position({
    fg = 'white',
    bg = 'light_purple',
})

Filesize = ui.filesize({
    fg = 'white',
    bg = 'darkblue',
})

-- OS WITH HOLO EFFECT
local ani = InContainer('components.factory.animations').init(ui_lib, colorscheme)

local holo = {
    fgl = ani.holo_fade('fg', 'black'),
    bg = ani.holo_fade('bg', 'gold'),
    fgr = ani.holo_fade('fg', 'green'),
}

function Holo_fade(comp, bindfn)
    bindfn(comp, holo['bg'])
    return comp
end

-- pill shape with holo effects
function HoloPillshape(c, bindfn)
    local ip = c[LINKED] or c
    for i, comp in pairs(ip) do
        local hlk = { 'fgl', 'bg', 'fgl' }
        local cp = stamp(comp)
        if c[LINKED] == nil then
            cp = comp
        end
        -- core got bg highlighting
        bindfn(cp, holo[hlk[i]])
    end
    return c
end

-- pill shape render will depend on the name of component
OsText = function()
    return rend.text(' ' .. rc.os, { fg = 'black', bg = 'white' })
end

local function link_fn(comp, dir, colorbg)
    _ = nil
    -- request for next bg color
    if comp == _ and dir == _ then
        return { bg = colorscheme['black'] }
    end

    local x = rend.bullet_shape(comp, dir, 'FLAME', colorbg)

    return x
end

OsPillShape = rend.pill_shape(OsText(), 'FLAME', { 'green' })
BsdText = rend.text('BSD    ', { bg = 'red', fg = 'gold' })
MonsterText = rend.text('    Neovim', { bg = 'nord', fg = 'white' })
OsLink = rend.component_linker({ OsText(), BsdText }, 1, 'right', link_fn)

function Pad(num)
    return rend.padding(num, 'black')
end

BSDSymbol = rend.pill_shape(MonsterText, 'FLAME', { 'black' })

Mode = ui.vimode_indicator({
    fg = 'white',
    bg = 'red',
})

-- COMPONENTS LOCATION GOES HERE!
-- mirroring issue fixed!
-- fixed : by moving left_link code to the bottom and right_link to top

-- allow mode to change color
RL = { Mode, PagePos, LinePos }
LL = { Filename, Vcs, Filesize }

-- components that are linked
function MakeCommonRL(ub)
    local linkbinder = make_linker_binder(2, ub.bind)
    CommonRightLink = rend.component_linker(RL, 1, 'left', link_fn)
    bgstash.setbg('modehl_bg', colorscheme['light_purple'])

    return linkbinder(CommonRightLink, 4, modehl.dynhl(ub, bgstash.init('modehl_bg')), 'right')
end

function MakeCommonLL(ub)
    local linkbinder = make_linker_binder(2, ub.bind)

    CommonLeftLink = rend.component_linker(LL, 1, 'right', link_fn)

    bgstash.setbg('filesize_bg', 'darkblue')
    linkbinder(CommonLeftLink, 3, empty_file.config, 'left')
    return CommonLeftLink
end

-- this function will modfied diag, last left and right element
-- left and right must the be the last component
local function set_statusline_bg(left, right, bg)
    local p = { left, right }
    local mut = bd_helper.uniq.get_key_set(p)
    for i, name in pairs(mut) do
        p[i][name]['highlight']['bg'] = bg
    end
end

local kep = {
    k1 = {
        highlight = {
            bg = 'red',
            fg = 'green',
        },
    },
}
local kep2 = {
    k2 = {
        providers = 'brbb',
        highlight = {
            bg = 'red',
            fg = 'green',
        },
    },
}

set_statusline_bg(kep, kep2, 'blue')
assert(kep['k1']['highlight']['bg'] == 'blue')
assert(kep2['k2']['highlight']['bg'] == 'blue')

Diagnostics = ui.diagnostic('black', rc.diagnostic)
SpacingText = rend.text(' ', {
    bg = 'black',
    fg = 'white',
})
