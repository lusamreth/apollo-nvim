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
vim.g.python3_host_prog = "usr/bin/python3.9"
vim.g.python_host_prog = "/usr/bin/python2.7"

require "nvim-treesitter.configs".setup {
    query_linter = {
        enable = true,
        use_virtual_text = true,
        lint_events = {"BufWrite", "CursorHold"}
    }
}

require("customcolor")
require("nv-statusline")
-- require("statusline")
require("nv-telescope")
require "nvim-treesitter.configs".setup {
    rainbow = {
        enable = true,
        extended_mode = true -- Highlight also non-parentheses delimiters, boolean or table: lang -> boolean
    }
}
vim.cmd("hi rainbowcol6 guifg=#f11652")

---- proritize signs[error comes first!]
--vim.fn.sign_place(16,"","LspDiagnosticsSignError","%", {priority="30"})
-- relating to lsp
--require("nv-compe")
require("nv-cmp")
require("lsp")
--rust conflict with lspinstall for some reason
require("lspinstall").setup {}
require("lsp.rust-lang")
--vim.cmd("au BufRead,BufNewFile *.rs silent! <cmd>lua print('rust?')")
--utility = bash,lua,vim
require("nv-bufferline")
require("colorizer").setup()
require("diagnostic_line")
function Reload()
    print("Reloaded!")
    vim.cmd("source %")
end
vim.api.nvim_set_keymap(
    "n",
    "<M-q>",
    "<cmd>lua require('scripts.bufdel').delete_buffer('%')<CR>",
    {noremap = true, silent = true}
)
vim.api.nvim_set_keymap("n", "<M-r>", "<cmd>lua Reload()<CR>", {noremap = true, silent = true})

--vim.cmd("nnoremap z :Grep<space>")
--require("nv-tree")
require("lsp.utility-lang")
require("plug-configs.hlsearch")
----require("scripts.debug")
require("plug-configs.layout")
require("lsp.nv-formatter")
require("plug-configs.nv-whichkey")
require("plug-configs.nv-term")
--vim.cmd("luafile ~/.config/nvim/lua/nv-tree.lua")
require("nv-settings")
require("keybinding")
require("nv-tree")

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
vim.cmd("syntax on")
