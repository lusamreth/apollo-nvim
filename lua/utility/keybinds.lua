local function map(mode,key,action,config)
    config = config or {}
    if type(config) ~= "table" then
        error("Require table config!",2)
    end
    local wrapped = "<cmd>" .. action .. "<cr>"
    return vim.api.nvim_set_keymap(mode, key, wrapped,config)
end

function BuildNore(mode,key, action,config)
    config = config or {}
    config["noremap"] = true
    config["silent"] = true
    return map(mode,key,action,config)
end

function Nnoremap(key,action,config)
    return BuildNore("n",key,action,config)
end

function Inoremap(key, action,config)
    return BuildNore("i",key,action,config)
end

function Xnoremap(key,action,config)
    return BuildNore("x",key,action,config)
end

function Nmap(key,action,config)
    return map("n",key,action,config)
end

function Imap(key,action,config)
    return map("i",key,action,config)
end

function Xmap(key,action,config)
    return map("x",key,action,config)
end


-- allow lua to call local function
Gbinder = {}
Gbinder.bind = function(func)
    local caller = function() return func() end
    return caller
end
