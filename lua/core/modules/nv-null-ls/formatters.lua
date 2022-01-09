local h = access_module('nv-null-ls.helpers')

-- compare filetypes

-- integrate custom formatter !
-- backup loading !!!
local formatters = {
  -- 'prettier',
  -- 'rustfmt',
  -- 'black',
  'fish_indent',
  {
    name = 'json',
    manual = true,
    config = {
      filetype = { 'json' },
      exe = 'jq',
      args = { '.' },
      stdin = false,
    },
  },

  {
    name = 'xml',
    manual = true,
    config = {
      filetype = { 'xml' },
      exe = 'xmllint',
      args = {
        '--format',
      },
      stdin = false,
    },
  },
  {
    name = 'shfmt',
    config = {
      extra_args = { '-i', '2', '-ci' },
    },
  },
  {
    name = 'stylua',
    config = {
      extra_args = { '--indent-width', '4' },
    },
  },
}

return h.BuiltinFactory(formatters, 'formatting')
