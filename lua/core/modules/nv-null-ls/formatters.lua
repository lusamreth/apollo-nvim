local h = access_module('nv-null-ls.helpers')

-- compare filetypes
-- integrate custom formatter !
-- backup loading !!!
local formatters = {
    -- 'prettier',
    'rustfmt',
    {
        name = 'black',
        config = {
            extra_args = { '--fast' },
        },
    },
    'prettierd',
    'eslint_d',
    'fish_indent',
    {
        name = 'json',
        manual = true,
        config = {
            filetype = { 'json' },
            exe = 'jq',
            args = { '.' },
            stdin = true,
        },

        interceptors = {
            err_handling = h.MakeInterceptor('parse%serror'),
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
            stdin = true,
        },
        -- capture is a callback function that take two args ; (data,halt)
        -- data : additional data that flow from stdout before arriving to
        -- the display handler(bufwriter)
        -- halt : option for which the spawner decide to stop the data from
        -- arriving to bufwriter
        interceptors = {
            err_handling = h.MakeInterceptor('parser%serror%s:'),
            -- err_handling = function(data, capture)
            --     local ma = string.gmatch(data, 'parser%serror')
            --     if ma() then
            --         capture(vim.split(data, '\n'), true)
            --     end
            -- end,
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

local spawner = access_module('nv-null-ls.spawner')

local function fmt_manual()
    local ma = {}
    local conv = spawner.CreateAutoConverter()
    ma.handle = function(fmt)
        conv.ConvertToAuto(fmt)
    end
    ma.build = function()
        return conv.build()
    end
    return ma
end

return h.BuiltinFactory(formatters, 'formatting', fmt_manual)
