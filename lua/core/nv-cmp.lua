local present, cmp = pcall(require, "cmp")

if not present then
    return
end

vim.opt.completeopt = "menuone,noselect"

local luasnip = require "luasnip"
luasnip.loaders.from_vscode.lazy_load()

local types = require("cmp.types")
local lspkind = require("lspkind")

local check_back_space = function()
    local col = vim.fn.col(".") - 1
    return col == 0 or vim.fn.getline("."):sub(col, col):match("%s")
end

local t = function(str)
    return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local function super_tab(fallback)
    if vim.fn.pumvisible() == 1 then
        vim.fn.feedkeys(t("<C-n>"), "n")
    elseif luasnip.expand_or_jumpable() then
        vim.fn.feedkeys(t("<Plug>luasnip-expand-or-jump"), "")
    elseif check_back_space() then
        vim.fn.feedkeys(t("<tab>"), "n")
    else
        fallback()
    end
end

local function reverse_tab(fallback)
    if vim.fn.pumvisible() == 1 then
        vim.fn.feedkeys(t("<C-p>"), "n")
    elseif require("luasnip").jumpable(-1) then
        vim.fn.feedkeys(t("<Plug>luasnip-jump-prev"), "")
    else
        fallback()
    end
end
local keymap = {
    ["<CR>"] = cmp.mapping.confirm {
        behavior = cmp.ConfirmBehavior.Replace,
        select = true
    },
    ["<C-d>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<Tab>"] = super_tab,
    -- ["<Tab>"] = function(fallback)
    --     if vim.fn.pumvisible() == 1 then
    --         vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<C-n>", true, true, true), "n")
    --     elseif require("luasnip").expand_or_jumpable() then
    --         vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>luasnip-expand-or-jump", true, true, true), "")
    --     else
    --         fallback()
    --     end
    -- end,
    ["<S-Tab>"] = reverse_tab
}

-- setting up lspkind
require("lspkind").init(
    {
        with_text = true
    }
)

local symbols_map = {
    Text = "",
    Method = "ƒ",
    Function = "",
    Constructor = "",
    Variable = "",
    Class = "",
    Interface = "ﰮ",
    Module = "",
    Property = "",
    Unit = "",
    Value = "",
    Enum = "了",
    Keyword = "",
    Snippet = "﬌",
    Color = "",
    File = "",
    Folder = "",
    EnumMember = "",
    Constant = "",
    Struct = ""
}

for kind, symbol in pairs(symbols_map) do
    symbol = string.format("%s (%s)", symbol, kind)
end

local function extend_symbol(s)
    for name, symbol in pairs(s) do
        require("lspkind").presets["default"][name] = symbol
    end
end

extend_symbol(symbols_map)

local format = {
    format = function(entry, vim_item)
        print("FORMATTING")
        vim_item.kind = lspkind.presets.default[vim_item.kind]

        vim_item.menu =
            ({
            nvim_lsp = "[LSP]",
            nvim_lua = "[Lua]",
            buffer = "[BUF]"
        })[entry.source.name]
        return vim_item
    end
}

DOC_HEIGHT = 40
DOC_WIDTH = DOC_HEIGHT * 2

cmp.setup(
    {
        sources = {
            {name = "luasnip"},
            {name = "buffer"},
            {name = "nvim_lsp"},
            {name = "nvim_lua"}
        },
        confirmation = {
            default_behavior = types.cmp.ConfirmBehavior.Insert
        },
        preselect = cmp.PreselectMode.None,
        -- preselect = types.cmp.PreselectMode.Item,
        documentation = {
            border = {"|", "-", "|", "+", "~", "", "", " "},
            winhighlight = "NormalFloat:CmpDocumentation,FloatBorder:CmpDocumentationBorder",
            maxwidth = math.floor((DOC_HEIGHT * 8) * (vim.o.columns / (DOC_HEIGHT * 2 * 16 / 9))),
            maxheight = math.floor(DOC_HEIGHT * (DOC_HEIGHT / vim.o.lines))
        },
        mapping = keymap,
        formatting = format,
        -- add snippet support
        snippet = {
            expand = function(args)
                require("luasnip").lsp_expand(args.body)
            end
        }
    }
)

-- vim.api.nvim_set_keymap("i", "<C-E>", "<Plug>luasnip-next-choice", {})
-- vim.api.nvim_set_keymap("s", "<C-E>", "<Plug>luasnip-next-choice", {})
