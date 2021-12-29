-- config doc height and width
print("CMP IMPORTED")
DOC_HEIGHT = 40
DOC_WIDTH = DOC_HEIGHT * 2

local present, cmp = pcall(require, "cmp")
if not present then
    return
end

vim.opt.completeopt = "menuone,noselect"

local luasnip = require "luasnip"
local types = require("cmp.types")

local util_types = require("luasnip.util.types")
vim.api.nvim_command("hi LuasnipChoiceNodePassive cterm=italic")
require("luasnip.loaders.from_vscode").lazy_load()

luasnip.config.setup(
    {
        ext_opts = {
            [util_types.insertNode] = {
                passive = {
                    hl_group = "GruvboxRed"
                }
            },
            [util_types.choiceNode] = {
                active = {
                    virt_text = {{"choiceNode", "GruvboxOrange"}}
                }
            },
            [util_types.textNode] = {
                snippet_passive = {
                    hl_group = "GruvboxGreen"
                }
            }
        },
        ext_base_prio = 200,
        ext_prio_increase = 3
    }
)

local check_back_space = function()
    local col = vim.fn.col(".") - 1
    return col == 0 or vim.fn.getline("."):sub(col, col):match("%s")
end

local t = function(str)
    return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local function super_tab(fallback)
    if cmp.visible() then
        cmp.select_next_item()
    elseif luasnip.expand_or_jumpable() then
        vim.fn.feedkeys(t("<Plug>luasnip-expand-or-jump"), "")
    elseif check_back_space() then
        vim.fn.feedkeys(t("<tab>"), "n")
    else
        fallback()
    end
end

local function reverse_tab(fallback)
    if cmp.visible() then
        cmp.select_prev_item()
    elseif require("luasnip").jumpable(-1) then
        vim.fn.feedkeys(t("<Plug>luasnip-jump-prev"), "")
    else
        fallback()
    end
end

local keymap = {
    ["<Tab>"] = super_tab,
    ["<S-Tab>"] = reverse_tab,
    ["<CR>"] = cmp.mapping.confirm {
        behavior = cmp.ConfirmBehavior.Replace,
        select = true
    },
    ["<C-d>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete()
}
local symbols_map = {
    Text = " ",
    Method = "",
    Function = "λ",
    -- Constructor = "",
    Constructor = "",
    Field = "ﴲ ",
    Variable = "",
    Class = "ﴯ",
    Interface = "",
    Module = " ",
    Property = "﴾",
    Unit = "塞",
    Value = "ﲹ",
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
    Operator = "",
    TypeParameter = " "
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
        vim_item.kind = string.format("%s %s", symbols_map[vim_item.kind], vim_item.kind)
        vim_item.menu =
            ({
            nvim_lsp = "[LSP]",
            nvim_lua = "[Lua]",
            buffer = "[BUF]",
            luasnip = "[SNIP]"
        })[entry.source.name]

        return vim_item
    end
}

cmp.setup(
    {
        sources = {
            {name = "nvim_lsp"},
            {name = "nvim_lua"},
            {name = "luasnip"},
            {name = "buffer"}
        },
        confirmation = {
            default_behavior = types.cmp.ConfirmBehavior.Insert
        },
        -- preselect = cmp.PreselectMode.None,
        preselect = types.cmp.PreselectMode.Item,
        expiremental = {
            native_menu = false,
            ghost_text = true
        },
        documentation = {
            border = {
                BORDERTOPLEFT,
                BORDERVERTICAL,
                BORDERTOPRIGHT,
                BORDERHORIZONTAL,
                BORDERBOTRIGHT,
                BORDERVERTICAL,
                BORDERBOTLEFT,
                BORDERHORIZONTAL
            },
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
