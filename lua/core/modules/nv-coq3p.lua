require("coq_3p")(
    {
        {src = "nvimlua", short_name = "nLUA"},
        {src = "vimtex", short_name = "vTEX"},
        {src = "demo"},
        {
            src = "repl",
            sh = "zsh",
            shell = {p = "python", n = "node"},
            max_lines = 99,
            deadline = 500,
            unsafe = {"rm", "poweroff", "mv", "trash", "kill"}
        },
        {src = "bc", short_name = "MATH", precision = 6}
    }
)

local symbols_map = {
    Text = " ",
    Method = "",
    Function = "",
    -- Constructor = "",
    Constructor = "",
    Field = "ﴲ ",
    Variable = "",
    Class = "ﴯ",
    Interface = "",
    Module = " ",
    Property = "",
    Unit = "塞",
    Value = "",
    Enum = "",
    Keyword = "",
    Snippet = "  ",
    Color = "",
    File = "",
    Reference = "",
    Folder = "",
    EnumMember = "",
    Constant = "ﲀ",
    Struct = "ﳤ",
    Event = "",
    Operator = "",
    TypeParameter = " "
}

vim.g.coq_settings = {
    ["clients.tabnine.enabled"] = true,
    auto_start = "shut-up",
    keymap = {
        jump_to_mark = "<c-q>",
        recommended = false,
        pre_select = true
    },
    display = {
        icons = {
            mappings = symbols_map
        }
    }
}

local luasnip = require "luasnip"

local check_back_space = function()
    local col = vim.fn.col(".") - 1
    return col == 0 or vim.fn.getline("."):sub(col, col):match("%s")
end

local t = function(str)
    return vim.api.nvim_replace_termcodes(str, true, true, true)
end

function sup()
    if vim.fn.pumvisible() == 1 then
        vim.fn.feedkeys(t("<C-n>"), "n")
    elseif luasnip.expand_or_jumpable() then
        vim.fn.feedkeys(t("<Plug>luasnip-expand-or-jump"), "")
    elseif check_back_space() then
        vim.fn.feedkeys(t("<tab>"), "n")
    else
        print("Fallback")
    end
end

_G.smart_tab = function()
    if vim.fn.pumvisible() == 1 then
        return t "<C-n>"
    else
        return t "<Tab>"
    end
end

local check_back_space = function()
    local col = vim.fn.col(".") - 1
    if col == 0 or vim.fn.getline("."):sub(col, col):match("%s") then
        return true
    else
        return false
    end
end

-- Use (s-)tab to:
--- move to prev/next item in completion menuone
--- jump to prev/next snippet's placeholder
vim.cmd("set completeopt=menuone,noinsert,noselect")
