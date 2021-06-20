--noremap <silent> n <Cmd>execute('normal! ' . v:count1 . 'n')<CR>
--            \<Cmd>lua require('hlslens').start()<CR>
--noremap <silent> N <Cmd>execute('normal! ' . v:count1 . 'N')<CR>
--            \<Cmd>lua require('hlslens').start()<CR>
 
require("utility.keybinds")
-- args :-n = go forward the highlight letter
--       -N = go backward the highlight letter
function toggle_search(mode)
    local hls = require("hlslens");
    local command = string.format("execute('normal! ' . v:count1 . '%s')",mode)
    vim.cmd(command)
    hls.start()
end

local goforward = function ()
    print('goforward')
    toggle_search("n")
end

local gobackward = function()
    toggle_search("N")
end

CallerF = Gbinder.bind(goforward)
CallerB = Gbinder.bind(gobackward)

Nnoremap("m","lua CallerF()",{
    silent = true
})

Nnoremap("n","lua CallerB()",{ 
    silent = true
})

Nnoremap("* *","lua require('hlslens').start()",{silent = true})
Nnoremap("# #","lua require('hlslens').start()",{silent = true})
Nnoremap(",l","lua vim.cmd('nohl')",{silent = true})