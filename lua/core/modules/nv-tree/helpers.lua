local opt = vim
local mod = {}

local hitreefolder = function(treetype, col)
    local hi = string.format('hi nvimtreefolder%s guifg=%s', treetype, col)
    vim.cmd(hi)
end

mod.hlconfig = function()
    if firstrun > 0 then
        return
    else
        -- if colorscheme is use will be override
        hitreefolder('icon', '#51afef')
        hitreefolder('name', '#ec5f67')
        hitreefolder('imagefile', '#p25f67')
        hitreefolder('openedfoldername', '#111111')
        hitreefolder('marker', '#p25f67')
    end
    firstrun = 1
end

mod.extend_bufferline = function()
    if package.loaded['bufferline.state'] then
        require('bufferline.state').set_offset(30 + 1, '')
    end
end

-- mappings for nvimtree
function customtreetoggle()
    local success, _ = pcall(mod.hlconfig, nil)
    assert(success, 'failed on opening tree hook!')
    opt.cmd('NvimTreeToggle')
end

mod.tree_hook = function(hooks)
    local function runhook(kind)
        local hk = hooks
        assert(hk ~= nil, 'unavailable hook!')

        if #hk == 0 then
            return
        end

        for name, hookfn in pairs(hk) do
            local success, _ = pcall(hookfn, nil)
            assert(success, 'failed on opening tree hook! name : [' .. name .. ']')
            hookfn()
        end
    end

    caller = Gbinder.bind(function()
        return runhook('close')
    end)

    vim.cmd('au winclosed * lua caller()')

    return function()
        runhook('open')
        vim.cmd('NvimTreeToggle')
    end
end

return mod
