require('utility.binding')
-- args :-n = go forward the highlight letter
--       -N = go backward the highlight letter
require('hlslens').setup()

local function toggle_search(mode)
    local hls = require('hlslens')
    local command = string.format("execute('normal! ' . v:count1 . '%s')", mode)
    vim.cmd(command)
    hls.exportLastSearchToQuickfix()
end

local goforward = function()
    toggle_search('n')
end

local gobackward = function()
    toggle_search('N')
end

CallerF = Gbinder.bind(goforward)
CallerB = Gbinder.bind(gobackward)

Nnoremap('m', 'lua CallerF()')

Nnoremap('n', 'lua CallerB()')

Nnoremap('* *', "lua require('hlslens').start()", { silent = true })
Nnoremap('# #', "lua require('hlslens').start()", { silent = true })
Nnoremap(',l', "lua vim.cmd('nohl')", { silent = true })
