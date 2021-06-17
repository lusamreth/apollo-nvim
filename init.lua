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
--[[ 
SOURCING ONLY HEHEHEHEHE!

 Some style ◕‿↼
 http://github.com/mitchweaver/dots
 ▜▘   ▗▐  
 ▐ ▛▀▖▄▜▀ 
 ▐ ▌ ▌▐▐ ▖
 ▀▘▘ ▘▀▘▀ 
]]
--(ゝз◇)INIT!!

vim.cmd('source $HOME/.config/nvim/plugins.vim')
--vim.cmd('source $HOME/.config/nvim/plug-config/nerdtree.vim')
--vim.cmd('source $HOME/.config/nvim/settings/keybinds.vim')
--vim.cmd('source $HOME/.config/nvim/settings/general.vim')
vim.cmd('source $HOME/.config/nvim/settings/themes.vim')
vim.cmd('source $HOME/.config/nvim/plug-config/doc_writing.vim')
vim.cmd('source $HOME/.config/nvim/plug-config/terminals.vim')
vim.cmd('source $HOME/.config/nvim/plug-config/languages.vim')
vim.cmd('source $HOME/.config/nvim/scripts/index.vim')

vim.g.python3_host_prog = '$HOME/python3.10.0a7/bin/python3.10'
vim.g.python_host_prog = '/usr/bin/python2'
vim.g.node_host_prog = '/usr/bin/neovim-node-host'
-- semantics : 
-- highlight {forground,background}

-- lua settings
require "nvim-treesitter.configs".setup {
  query_linter = {
    enable = true,
    use_virtual_text = true,
    lint_events = {"BufWrite", "CursorHold"},
  },
}

require("customcolor")
require("statusline")
require("nv-telescope")
require'nvim-treesitter.configs'.setup {
  rainbow = {
    enable = true,
    extended_mode = true, -- Highlight also non-parentheses delimiters, boolean or table: lang -> boolean
  }
}
vim.cmd('hi rainbowcol6 guifg=#f11652')

---- proritize signs[error comes first!]
--vim.fn.sign_place(16,"","LspDiagnosticsSignError","%", {priority="30"})
-- relating to lsp
require("nv-compe")
require("lsp")
--rust conflict with lspinstall for some reason
require("lspinstall").setup{}
require("lsp.rust-lang")
--vim.cmd("au BufRead,BufNewFile *.rs silent! <cmd>lua print('rust?')")
--utility = bash,lua,vim
require("lsp.appearance")
require("nv-bufferline")
require ("colorizer").setup()
require("diagnostic_line")
function Reload()
    print("Reloaded!")
    local loaded = {"nv-bufferline","colorizer","nv-saga"}
    --local loaded = package.loaded
    require("utility")
    --print(split(vim.bo.get_filename(),"."))
    local ft = FileType()
    if  ft == "vim" then
        return "source %"
    else
        if ft == "lua" then

            --require("plenary.reload").reload_module(loaded[1])
            for _,modname in pairs(loaded) do
                if package.loaded[modname] then 
                    vim.cmd("silent! write")
                    package.loaded[modname] = nil
                    require(modname)
                    --require("plenary.reload").reload_module(x)
                end
            end
        end
    end
end
vim.api.nvim_set_keymap("n","<M-q>","<cmd>lua require('scripts.bufdel').delete_buffer('%')<CR>",{noremap = true,silent = true})
vim.api.nvim_set_keymap("n","<M-r>","<cmd>lua Reload()<CR>",{noremap = true,silent = true})

--vim.cmd("nnoremap z :Grep<space>")
--require("nv-tree")
require("lsp.utility-lang")
require("plug-configs.hlsearch")
--require("scripts.debug")
require("plug-configs.layout")
require("lsp.nv-formatter")
require("plug-configs.nv-whichkey")
require("plug-configs.nv-term")
require("settings")
require("keybinding")
--require("nv-tree")
vim.cmd("luafile ~/.config/nvim/lua/nv-tree.lua")

require('nvim_comment').setup(
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
})
require("utility.test")
function TestTb()
    Describe("tableclonetest",function()
        local arr = {1,2,3,5,6,7}
        local cloned = table_clone(arr)
        AssertEquals(arr,cloned)
    end)

    Describe("tablemergetest",function()
        local res = {1,2,3,5,6,7}
        local arr1 = {1,2,3}
        local arr2 = {4,5,6,7}
        AssertEquals(res,table_merge(arr1,arr2))
    end)
end

