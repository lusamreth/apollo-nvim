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
require("impatient")
require("plugins")

vim.g.python3_host_prog = "usr/bin/python3.9"
vim.g.python_host_prog = "/usr/bin/python2.7"

-- this custom loader must be loaded first before the system
-- starts sourcing core files and plugins
require("utility")
_G.HOMEROOT = "/home/lusamreth"
_G.LUAROOT = HOMEROOT .. "/nvim-proto-2/lua"

_G.import = function(mod, root, use_require)
    -- use_require = true
    if use_require then
        local s = Splitstr(root, "/")
        print("+===>", s[1], s[#s - 1])
        return require(mod)
    end
    -- print("importing", mod)
    root = root or LUAROOT .. "/"
    local succ, res = pcall(Splitstr, mod, ".")

    if succ == true then
        local full = ""
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

local original_import = import

local function reset_import()
    _G.import = original_import
end
_G.make_import = function(root)
    return function(mod)
        return import(mod, root)
    end
end

function _G.access_core(mod, dir)
    dir = dir or "nvim-proto-2"
    return import(mod, "/home/lusamreth/" .. dir .. "/lua/core/")
end

function _G.access_module(mod)
    return access_core("modules." .. mod)
end

function _G.access_system(mod)
    return import("system." .. mod)
end

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

-- start importing modules(plugin configs)
access_module("nv-hlsearch")
access_module("nv-layout")
access_module("nv-projects")
access_module("nv-whichkey")
access_module("nv-term")
access_module("nv-bufferline")
access_module("nv-tree")

require("rust-tools").setup({})
access_core("lsp.init")

require("configs.nv-settings")
require("configs.keybinding")

vim.cmd("luafile " .. HOMEROOT .. "/nvim-proto-2/lua/core/lsp/languages/utility-lang.lua")
vim.cmd("luafile " .. HOMEROOT .. "/nvim-proto-2/lua/core/lsp/languages/rust-lang.lua")
access_system("inspectors.table")
access_system("inspectors.interface-builder")

-- statusline mutate the original import
vim.cmd("luafile ~/nvim-proto-2/lua/core/statusline/init.lua")
reset_import()
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
