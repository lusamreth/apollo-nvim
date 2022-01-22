-- Trait keybinder
-- require- register(m,k,a,c)
-- require- prefix

local conf = {}
local function map(mode, key, action, config)
    config = config or {}
    if type(config) ~= 'table' then
        error('require table config!', 2)
    end

    local wrapped = '<cmd>' .. action .. '<cr>'
    if config['binder'] == true then
        wrapped = action
        config['binder'] = nil
    end

    if #conf > 0 then
        print('conf')
    end
    return vim.api.nvim_set_keymap(mode, key, wrapped, config)
end

vim.api.nvim_set_keymap('n', '<C-i>', '<C-w>j', { silent = true })

function BuildNore(mode, key, action, config)
    config = config or {}
    config['noremap'] = true
    config['silent'] = true
    return map(mode, key, action, config)
end

function Nnoremap(key, action, config)
    return BuildNore('n', key, action, config)
end

function Inoremap(key, action, config)
    return BuildNore('i', key, action, config)
end

function Xnoremap(key, action, config)
    return BuildNore('x', key, action, config)
end

function Tnoremap(key, action, config)
    action = '<C-\\><C-N>' .. action
    return BuildNore('x', key, action, config)
end

function Vnoremap(key, action, config)
    return BuildNore('v', key, action, config)
end

-- normal
function Nmap(key, action, config)
    return map('n', key, action, config)
end

function Imap(key, action, config)
    return map('i', key, action, config)
end

function Xmap(key, action, config)
    return map('x', key, action, config)
end

function Vmap(key, action, config)
    return map('v', key, action, config)
end

Create_command = function(name, func)
    vim.cmd('command! -nargs=* ' .. name .. ' lua ' .. func)
end

function Command_to_func_name(commands, config)
    local res = {}
    config = config or {}
    for i, cmd in pairs(commands) do
        local s = cmd:sub(5)
        -- skipp first uppercase !
        local uindex = UpperCasePos(s:sub(2))
        local u1, u2 = uindex[1], uindex[2]
        local arg, func

        if u1 ~= nil then
            local firstChunk = s:sub(1, u1)
            local remain

            --
            if u2 ~= nil and config['last_isarg'] then
                arg = s:sub(u2 + 1)

                remain = s:sub(u1 + 1, u2)
            else
                remain = s:sub(u1 + 1)
            end

            -- apply prefix and suffix
            local pre, suf = '', ''
            if config['prefix'] then
                pre = config['prefix'] .. '_'
            elseif config['suffix'] then
                suf = '_' .. config['suffix']
            end

            func = pre .. string.lower(firstChunk .. '_' .. remain) .. suf
        else
            func = string.lower(s)
        end

        res[i] = { func, arg }
    end
    return res
end

local function select_element(nest, index)
    local res = {}
    for i, c in pairs(nest) do
        if type(c) == 'table' then
            res[i] = c[index]
        end
    end
    return res
end

function Scrap_keybinds(group, leader)
    local res = {}
    leader = leader or ''
    for n, c in pairs(group) do
        if type(c) == 'table' and n ~= 'config' then
            local key, cmd = leader .. c[1], c[2]
            res[key] = cmd
        end
    end
    return res
end

-- make_command will define how each command is produced and bind to the function
-- it will also responsible on how the function got retrieved and call !
function Create_command_key_pair(key_command_pair, make_command, leader)
    local function bind_to_key(group)
        local kb = Scrap_keybinds(group, leader)
        for key, cmd in pairs(kb) do
            Nnoremap(key, cmd)
        end
    end

    for _, group in pairs(key_command_pair) do
        local option = group['config']

        -- use_arg require collector which define how to utilize last
        -- slice of string
        local cmds = select_element(group, 2)
        make_command(cmds, option)
        bind_to_key(group)
    end
end

-- allow lua to directly call local function
Gbinder = {}
Gbinder.bind = function(func)
    local caller = function()
        return func()
    end
    return caller
end
