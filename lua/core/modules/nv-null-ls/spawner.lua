local loop = vim.loop

-- for some reason i cannot extract err data
SPAWN = function(command, args, onread, onexit)
    local stdin = loop.new_pipe()
    local stdout = loop.new_pipe(false) -- create file descriptor for stdout
    local stderr = loop.new_pipe(false) -- create file descriptor for stdout
    Handle = loop.spawn(
        command,
        {
            args = args,
            stdio = { stdin, stdout, stderr },
        },

        vim.schedule_wrap(function()
            stdout:read_stop()
            stderr:read_stop()
            stdout:close()
            stderr:close()
            -- function exec before closing
            onexit()
            Handle:close()
        end)
    )
    loop.read_start(stdout, onread) -- TODO implement onread handler
    loop.read_start(stderr, onread)
end

local function write_to_buf(data, bufnr)
    local new_lines
    if type(data) == 'table' then
        new_lines = data
    else
        if data == nil then
            -- error('Potential Error! Please Fixed The error before proceeding!')
            return
        else
            new_lines = vim.split(data, '\n')
        end
    end

    -- check for errors
    if string.find(new_lines[#new_lines], '^# exit %d+') then
        error(string.format('failed to format with prettier: %s', data))
    end
    -- write contents
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, new_lines)
end

local ui = access_system('ui.init')

local isOpen

-- isOpen can only handle once at a time
local function interceptor_display_handler(text)
    if isOpen then
        return
    end

    local txt = ui.text(text).border('orange').build()

    local win = ui.win.CreatePopup(txt, {
        enter = false,
        position = {
            col = '10%',
            row = '90%',
        },
    })

    if not isOpen then
        win.open()
    end
    local close_timer = vim.loop.new_timer()

    close_timer:start(
        3000,
        0,
        vim.schedule_wrap(function()
            win.close()
            isOpen = false
        end)
    )

    isOpen = true
end

local function interceptor_display(interceptors, data, captures)
    for _, interceptor in pairs(interceptors) do
        local success, in_data = pcall(interceptor, data, function(dt, ishalt)
            captures.data = dt
            captures.halted = ishalt
        end)

        if success and captures.data ~= nil then
            vim.validate({
                {
                    captures['data'],
                    't',
                },
                {
                    captures['halted'],
                    'b',
                },
            })

            vim.schedule(function()
                interceptor_display_handler(captures.data)
            end)
        elseif not success then
            in_data = in_data or 'Not Specified'
            error('INTERNAL ERROR : ' .. in_data)
        end
    end
end

local function spawn_formatter(cmd, args, opts)
    local res = {}
    local captures = {}

    local function send_to_res(err, data)
        print('DATA', vim.inspect(data))
        if err then
            error('Formatter got error!', error)
        end
        local interceptors = opts['interceptors'] or false

        if interceptors and data ~= nil then
            interceptor_display(interceptors, data, captures)
        end

        table.insert(res, data)
    end

    local function retrieve_to_buf()
        if captures.halted or isOpen then
            return
        end

        local bufnr = vim.api.nvim_get_current_buf()
        for i, r in pairs(res) do
            res[i] = AllTrim(r)
        end

        write_to_buf(res[1], bufnr)
        vim.cmd('w')
    end
    SPAWN(cmd, args, send_to_res, retrieve_to_buf)
end

FormatAutoCmd = {}
ManualExt = {}

import('utility.init')
import('utility.binding')

function MakeFmtFunc(config)
    local c = config['config']
    vim.validate({
        {
            c['exe'],
            's',
        },
        {
            c['args'] or {},
            't',
        },
    })

    local exec, arg = c['exe'], c['args']
    local last = #arg + 1
    local opts = {}
    if config['interceptors'] then
        opts['interceptors'] = config['interceptors']
    end
    return function()
        local currentbuf = vim.api.nvim_buf_get_name(0)
        -- will litherally pass the string of current buffer content
        -- to process formatting
        if config['RequireRawInput'] then
            local bufnr = vim.api.nvim_get_current_buf()
            currentbuf = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
            local total_line = ''
            for _, line in pairs(currentbuf) do
                total_line = total_line .. line
            end
            currentbuf = total_line
        end

        arg[last] = currentbuf
        spawn_formatter(exec, arg, opts)
    end
end

-- Global variable no good!
-- use to create manual augroup
-- format_lookup contains functions that run formatters executable !!

local function init_manual(MnExt, hook, format_lookup)
    local res = {}
    if #MnExt == 0 then
        return
    end
    -- default fallback
    if format_lookup == nil then
        format_lookup = FormatAutoCmd
    end

    for i, ext in pairs(MnExt) do
        --local s = string.format("lua FormatAutoCmd['%s']()", ext)
        local ext_string = ext
        if type(ext) ~= 'string' then
            ext_string = table.concat(ext, ' ')
        end

        function _Invoke_formatter(e)
            format_lookup[e]()
        end

        local s = string.format('lua _Invoke_formatter("%s")', ext_string)
        res[i] = { hook, '*.' .. ext_string, s }
    end

    return res
end

local M = {}

function HandleAugroup(exts, lookup_tb)
    local hook = 'BufWritePost'
    local Group = init_manual(exts, hook, lookup_tb)
    Create_augroup(Group, 'FormatAutogroup')
end

function M.CreateAutoConverter()
    local extensions = {}
    local res = {}
    FMT_CMD = {}

    function res.ConvertToAuto(formatter)
        local ext

        if formatter['config']['filetype'] == nil then
            ext = formatter['name']
        else
            ext = table.concat(formatter['config']['filetype'], '')
        end
        table.insert(extensions, ext)
        FMT_CMD[ext] = MakeFmtFunc(formatter)
    end

    function res.build()
        if extensions == {} or extensions == nil then
            error('Error Detecting formatter !! Please check ur filetype configs')
            return
        end
        -- print('AFTER HANDLED', vim.inspect(FMT_CMD))
        HandleAugroup(extensions, FMT_CMD)
    end
    return res
end

return M
