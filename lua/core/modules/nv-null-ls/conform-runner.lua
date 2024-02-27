local conform = require('conform')
local util = require('conform.util')

CONTROL_VARIABLES = {
    rollback = false,
    async_on_save_fal = true,
    -- debug_mode = true,
    debug_mode = false,
    lsp_fallback = true,
    injected_formatter = true,
}

local debug_printer = function(msg)
    cvar = CONTROL_VARIABLES
    enabled = cvar['debug_mode']

    if not enabled then
        return
    end

    print(msg)
end

local slow_format_filetypes = {}
local opts = {
    formatters_by_ft = {
        lua = { 'stylua' },
        cpp = { 'clang-format' },
        -- Conform will run multiple formatters sequentially
        python = { 'isort', 'black' },
        json = { 'fixjson', 'jq' },
        xml = { 'xmlformat' },
        yaml = { 'yamlfix', 'yamlformat' },
        rust = { 'rustfmt' },
        sh = { 'shfmt' },
        -- Use a sub-list to run only the first available formatter
        -- javascript = { { 'prettierd', 'prettier' } },
        ['*'] = { 'codespell' },
        ['_'] = { 'trim_whitespace' },
    },
    format_on_save = {
        -- These options will be passed to conform.format()
        timeout_ms = 300,
        lsp_fallback = true,
    },
    formatters = {},
    --     stylua = {
    --         -- inherit = false,
    --         command = "stylua",
    --         args = { "--indent-width", "4" ,"$FILENAME"}
    --     }

    -- },
}
local modifiedFormatter = {}

function addFormatterArgs(formatter_name, args)
    local fpkg = string.format('conform.formatters.%s', formatter_name)
    modifiedFormatter[formatter_name] = {
        init_format = function()
            return {
                prepend_args = args,
            }
        end,
        args = args,
    }
end

addFormatterArgs('shfmt', { '-i', '2', '-ci' })
addFormatterArgs('stylua', { '--indent-width', 4 })

function enableSlowAsyncFallback(opt, control_var)
    debug_printer('Slow async switching enable!')
    lspFallback = control_var['lsp_fallback'] or true
    fmtOnSave = function(bufnr)
        if slow_format_filetypes[vim.bo[bufnr].filetype] then
            return
        end

        local function on_format(err)
            if err and err:match('timeout$') then
                slow_format_filetypes[vim.bo[bufnr].filetype] = true
            end
        end

        return { timeout_ms = 200, lsp_fallback = lspFallback }, on_format
    end

    fmtPostSave = function(bufnr)
        if not slow_format_filetypes[vim.bo[bufnr].filetype] then
            return
        end
        return { lsp_fallback = lspFallback }
    end

    -- opt["format_on_save"] = fmtOnSave
    opt['format_after_save'] = fmtPostSave
end

-- this function allow you to swap stock config with overrided one
-- pretty easily without directly modified the stock config
function overrideFormatterWithExtraCfg(opt, control_var)
    -- refused to override

    debug_printer('Overriding the stock format runner arguments')
    ftFormatterCfg = opt['formatters_by_ft']
    for fname, modifiedOpt in pairs(modifiedFormatter) do
        local setupFormatter = modifiedFormatter[fname].init_format
        debug_printer(vim.inspect(modifiedOpt))
        opt['formatters'][fname] = setupFormatter()
    end
end

function controlNode(opt, control_var)
    debug_printer('Control node enable!')
    if control_var['rollback'] then
        debug_printer('Control node disabled. System rollback !!!')
        return
    end

    if control_var['async_on_save_fallback'] then
        enableSlowAsyncFallback(opt, control_var)
    end

    if control_var['injected_formatter'] then
        -- Set this value to true to silence errors when formatting a block fails
        require('conform.formatters.injected').options.ignore_errors = false
    end

    overrideFormatterWithExtraCfg(opt, control_var)
    return opts
end

local controlled_opts = controlNode(opts, CONTROL_VARIABLES)
conform.setup(controlled_opts)
