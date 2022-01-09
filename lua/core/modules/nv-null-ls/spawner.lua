local loop = vim.loop
SPAWN = function(command, args, onread, onexit)
    local stdout = loop.new_pipe(false) -- create file descriptor for stdout
    local stderr = loop.new_pipe(false) -- create file descriptor for stdout
    Handle = loop.spawn(
        command,
        {
            args = args,
            stdio = { stdout, stderr },
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
            print('Potential Error!')
        end

        new_lines = vim.split(data, '\n')
    end

    -- check for errors
    if string.find(new_lines[#new_lines], '^# exit %d+') then
        error(string.format('failed to format with prettier: %s', data))
    end
    -- write contents
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, new_lines)
end

function ManualFormat(cmd, args)
    local res = {}
    local function send_to_res(err, data)
        if err then
            error('Formatter got error!', error)
        end

        table.insert(res, data)
    end

    local function retrieve_to_buf()
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
            c['args'],
            't',
        },
    })

    local exec, arg = c['exe'], c['args']
    local last = #arg + 1

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
        ManualFormat(exec, arg)
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

M = {}
-- polymorph !, require extensions and format functions
-- function M.ConvertToAuto(formatter)
--     local ext

--     if formatter['config']['filetype'] == nil then
--         ext = formatter['name']
--     else
--         ext = formatter['config']['filetype']
--     end

--     table.insert(ManualExt, ext)
--     FormatAutoCmd[ext] = MakeFmtFunc(formatter)
-- end

-- test
-- single argument
-- ConvertToAuto({
--     name = 'json',
--     config = {
--         exe = 'jq',
--         args = { '.' },
--     },
-- })

function HandleAugroup(exts, lookup_tb)
    local hook = 'BufWritePost'
    local Group = init_manual(exts, hook, lookup_tb)
    Create_augroup(Group, 'FormatAutogroup')
end

function M.CreateAutoConverter(extensions)
    -- local extensions = {}
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

        HandleAugroup(extensions, FMT_CMD)
    end
    return res
end

-- HandleAugroup(ManualExt)

-- Create_command('ExpandFormat', 'print( vim.inspect(Group) )')
-- FmtSetup()

return M
