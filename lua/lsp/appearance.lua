require('lspkind').init({
     with_text = true,
     symbol_map = {
       Text = '',
       Method = 'ƒ',
       Function = '',
       Constructor = '',
       Variable = '',
       Class = '',
       Interface = 'ﰮ',
       Module = '',
       Property = '',
       Unit = '',
       Value = '',
       Enum = '了',
       Keyword = '',
       Snippet = '﬌',
       Color = '',
       File = '',
       Folder = '',
       EnumMember = '',
       Constant = '',
       Struct = ''
     },
})


-- credit goes to  LeonGr/show_line_diagnostics_bordered.lua

--let width = min([&columns - 4, max([80, &columns - 20])])
--let height = min([&lines - 4, max([20, &lines - 10])])

