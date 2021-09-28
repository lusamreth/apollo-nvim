-- Trait keybinder
-- require- register(m,k,a,c)
-- require- prefix

local conf = {}
local function map(mode, key, action, config)
    config = config or {}
    if type(config) ~= "table" then
        error("require table config!", 2)
    end

    local wrapped = "<cmd>" .. action .. "<cr>"
    if config["binder"] == true then
        wrapped = action
        config["binder"] = nil
    end

    if #conf > 0 then
        print("conf")
    end
    return vim.api.nvim_set_keymap(mode, key, wrapped, config)
end

vim.api.nvim_set_keymap("n", "<C-i>", "<C-w>j", {silent = true})

function BuildNore(mode, key, action, config)
    config = config or {}
    config["noremap"] = true
    config["silent"] = true
    return map(mode, key, action, config)
end

function Nnoremap(key, action, config)
    return BuildNore("n", key, action, config)
end

function Inoremap(key, action, config)
    return BuildNore("i", key, action, config)
end

function Xnoremap(key, action, config)
    return BuildNore("x", key, action, config)
end

function Tnoremap(key, action, config)
    action = "<C-\\><C-N>" .. action
    return BuildNore("x", key, action, config)
end

function Nmap(key, action, config)
    return map("n", key, action, config)
end

function Imap(key, action, config)
    return map("i", key, action, config)
end

function Xmap(key, action, config)
    return map("x", key, action, config)
end

function Xmap(key, action, config)
    return map("v", key, action, config)
end

-- allow lua to call local function
Gbinder = {}
Gbinder.bind = function(func)
    local caller = function()
        return func()
    end
    return caller
end
