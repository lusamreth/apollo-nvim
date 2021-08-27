local cmp = require("cmp")

local luasnip = require 'luasnip'
local types = require("cmp.types")
local lspkind = require("lspkind")

local keymap = {

    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<C-Space>'] = cmp.mapping.complete(),
	["<Tab>"] = function(fallback)
		if vim.fn.pumvisible() == 1 then
			vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<C-n>", true, true, true), "n")
		elseif vim.fn["vsnip#available"]() == 1 then
			vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>(vsnip-expand-or-jump)", true, true, true), "")
		else
			fallback()
		end
	end,
    ['<S-Tab>'] = function(fallback)
      if vim.fn.pumvisible() == 1 then
        vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<C-p>', true, true, true), 'n')
      elseif luasnip.jumpable(-1) then
        vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<Plug>luasnip-jump-prev', true, true, true), '')
      else
        fallback()
      end
    end,
}

-- setting up lspkind
require("lspkind").init({
	with_text = true,
})

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
	Struct = "",
}

local function extend_symbol()
	for name, symbol in pairs(symbols_map) do
		require("lspkind").presets["default"][name] = symbol
	end
end

extend_symbol(symbols_map)

local format = {
	format = function(entry, vim_item)
		vim_item.kind = lspkind.presets.default[vim_item.kind]
		return vim_item
	end,
}

WIDE_HEIGHT = 40

cmp.setup({
	sources = {
        { name = 'luasnip' },
		{ name = "buffer" },
		{ name = "nvim_lsp" },
		{ name = "nvim_lua" },
	},

    confirmation = {
      default_behavior = types.cmp.ConfirmBehavior.Insert,
    },
    preselect = types.cmp.PreselectMode.Item,
    documentation = {
      border = { '|', '-', '|', ' ', '', '', '', ' ' },
      winhighlight = 'NormalFloat:CmpDocumentation,FloatBorder:CmpDocumentationBorder',
      maxwidth = math.floor((WIDE_HEIGHT * 2) * (vim.o.columns / (WIDE_HEIGHT * 2 * 16 / 9))),
      maxheight = math.floor(WIDE_HEIGHT * (WIDE_HEIGHT / vim.o.lines)),
    },
	mapping = keymap,
	formatting = format,
    -- add snippet support
    snippet = {
      expand = function(args)
        require('luasnip').lsp_expand(args.body)
      end
    },
})


-- vim.api.nvim_set_keymap("i", "<C-E>", "<Plug>luasnip-next-choice", {})
-- vim.api.nvim_set_keymap("s", "<C-E>", "<Plug>luasnip-next-choice", {})
