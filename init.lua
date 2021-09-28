--[[

            "=================     ===============     ===============   ========  ========",
            "\\ . . . . . . .\\\\   //. . . . . . .\\\\   //. . . . . . .\\\\  \\\\. . .  //",
            "||. . ._____. . .|| ||. . ._____. . .|| ||. . ._____. . .|| || . . .\\/ . . .||",
            "|| . .||   ||. . || || . .||   ||. . || || . .||   ||. . || ||. . . . . . .  ||",
            "||. . ||   || . .|| ||. . ||   || . .|| ||. . ||   || . .|| || . | . . . . . ||",
            "|| . .||   ||. _-|| ||-_ .||   ||. . || || . .||   ||. _-|| ||-_.|\\ . . . . ||",
            "||. . ||   ||-'  || ||  `-||   || . .|| ||. . ||   ||-'  || ||  `|\\_ . .|. .||",
            "|| . _||   ||    || ||    ||   ||_ . || || . _||   ||    || ||   |\\ `-_/| . ||",
            "||_-' ||  .|/    || ||    \\|.  || `-_|| ||_-' ||  .|/    || ||   | \\  / |-_||",
            "||    ||_-'      || ||      `-_||    || ||    ||_-'      || ||   | \\  / |  `||",
            "||    `'         || ||         `'    || ||    `'         || ||   | \\  / |   ||",
            "||            .===' `===.         .==='.`===.         .===' /==. |  \\/  |   ||",
            "||         .=='   \\_|-_ `===. .==='   _|_   `===. .===' _-|/   `==  \\/  |  ||",
            "||      .=='    _-'    `-_  `='    _-'   `-_    `='  _-'   `-_  /|  \\/  |   ||",
            "||   .=='    _-'          '-__\\._-'         '-_./__-'         `' |. /|  |   ||",
            "||.=='    _-'                                                     `' |  /==. ||",
            "=='    _-'                         N V I M S                          \\/   `==",
            "\\   _-'                                                                `-_   /",
            " `''                                                                      ``'"
]]
require("plugins")

-- vim.cmd [[packadd packer.nvim]]
local packer = require("packer")
local use = packer.use
packer.reset()
packer.startup(
    function()
        print("startuping")
        use {"windwp/windline.nvim"}
    end
)
vim.g.python3_host_prog = "usr/bin/python3.9"
vim.g.python_host_prog = "/usr/bin/python2.7"

require "nvim-treesitter.configs".setup {
    query_linter = {
        enable = true,
        use_virtual_text = true,
        lint_events = {"BufWrite", "CursorHold"}
    },
    rainbow = {
        enable = true,
        extended_mode = true -- Highlight also non-parentheses delimiters, boolean or table: lang -> boolean
    }
}

-- require("customcolor")
-- require("nv-statusline")
-- require("statusline")
-- require("nv-telescope")

---- proritize signs[error comes first!]
--vim.fn.sign_place(16,"","LspDiagnosticsSignError","%", {priority="30"})
-- relating to lsp
--require("nv-compe")
-- require("nv-cmp")
require("lspinstall").setup {}
--vim.cmd("au BufRead,BufNewFile *.rs silent! <cmd>lua print('rust?')")
--utility = bash,lua,vim
require("colorizer").setup()
--require("diagnostic_line")
function Reload()
    print("Reloaded!")
    vim.cmd("source %")
end
vim.api.nvim_set_keymap("n", "<M-r>", "<cmd>lua Reload()<CR>", {noremap = true, silent = true})

--vim.cmd("nnoremap z :Grep<space>")
--require("nv-tree")
require("plug-configs.hlsearch")
----require("scripts.debug")
require("plug-configs.layout")
require("plug-configs.nv-projects")
-- require("lsp.nv-formatter")
require("plug-configs.nv-whichkey")
require("plug-configs.nv-term")
--vim.cmd("luafile ~/.config/nvim/lua/nv-tree.lua")
require("configs.nv-settings")
require("configs.keybinding")
require("core.nv-tree")

_G.HOMEROOT = "/home/lusamreth"
_G.LUAROOT = HOMEROOT .. "/nvim-proto-2/lua"

_G.make_import = function(root)
    return function(mod)
        return import(mod, root)
    end
end

_G.import = function(mod, root, use_require)
    if use_require then
        return require(mod)
    end
    -- print("importing", mod)
    root = root or _IMPORT.root
    local succ, res = pcall(split, mod, ".")
    if succ == true then
        local full = ""
        -- print(#res, res[1], res[2])
        for i, p in pairs(res) do
            local suffix = "/"
            if i == #res then
                suffix = ""
            end
            full = full .. p .. suffix
        end
        mod = full
    end
    local f, e = loadfile(root .. mod .. ".lua")
    if e then
        error("has error importing\n" .. e)
    end
    return f()
end

function _G.access_core(mod, dir)
    dir = dir or "nvim-proto-2"
    return import(mod, "/home/lusamreth/" .. dir .. "/lua/core/")
end

access_core("nv-bufferline")
access_core("nv-tree")
access_core("lsp.init")

vim.cmd("luafile " .. HOMEROOT .. "/nvim-proto-2/lua/core/lsp/languages/utility-lang.lua")
access_core("inspectors.table")
access_core("inspectors.interface-builder")
-- vim.cmd("luafile ~/nvim-proto-2/lua/core/scripts/freezer.lua")
-- vim.cmd("luafile ~/nvim-proto-2/lua/core/scripts/interface-builder.lua")
-- vim.cmd("luafile ~/nvim-proto-2/lua/nv-feline.lua")

-- require("feline").setup {
--     colors = {
--         fg = "#D0D0D0",
--         bg = "#1F1F23"
--     }
-- }

--print("BRUHHH", vim.g.statusline_winid, )

vim.cmd("luafile ~/nvim-proto-2/lua/core/statusline/init.lua")
require("nvim_comment").setup(
    {
        -- Linters prefer comment and line to have a space in between markers
        marker_padding = true,
        -- should comment out empty or whitespace only lines
        comment_empty = false,
        -- Should key mappings be created
        create_mappings = true,
        -- Normal mode mapping left hand side
        line_mapping = "gcc",
        -- Visual/Operator mapping left hand side
        operator_mapping = "gc"
    }
)

require("nvim-web-devicons").setup()
vim.cmd("syntax on")
