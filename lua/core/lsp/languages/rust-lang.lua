-- local _bedrock_prefix = "/bedrock/strata/arch"
local ui = access_system('ui.init')
local lsp = access_core('lsp.init')
-- lsp.on_common_attach(false)
Create_augroup({
    {
        'BufEnter,BufRead',
        '*.toml',
        "lua require('cmp').setup.buffer { sources = { { name = 'crates' } } }",
    },
}, 'lazy_cmp_crates_buffer')

local opts = {
    tools = {
        --show things such as tests / mod
        runnables = {
            use_telescope = true,
            -- rest of the opts are forwarded to telescope
        },
    },

    server = {
        -- standalone file support
        -- setting it to false may improve startup time
        standalone = true,
        on_attach = lsp.on_common_attach(false),
    }, -- rust-analyer options
}

local rust_tools = require('rust-tools')
rust_tools.setup(opts)

-- set inlay hints
-- default on!

-- collect is the fn for last slice of string
-- ex: ItemUp, Up need to be converted to arg

--example
--nest = {
--indx:{1 ,2}
--   {"1","a"}
--   {"2","b"}
--   .........
--}

local function create_rust_tool_cmd(cmds, option)
    local last
    if option then
        last = option['use_last'] or false
    end
    local res = Command_to_func_name(cmds, option)
    for i, com in pairs(res) do
        local func_arg, input = com[2] or '', ''
        if func_arg and last then
            input = option['collector'](func_arg)
        end

        local modname = AllTrim('rust-tools.' .. com[1])
        local func = 'require(' .. "'" .. modname .. "'" .. ').' .. com[1] .. '(' .. input .. ')'
        Create_command(cmds[i], func)
    end
end

local inlay_hints_dec = 'InlayHints : is for showing type in virtual_text!'
RustHints = {
    inlay_hints_dec,
    'Commands :',
    '    RustSetInlayHints : Set InlayHints option!',
    '    RustDisableInlayHints : Disable InlayHints options',
    '    RustToggleInlayHints : Enable InlayHints options',
    '    RustRunnables : Good for testing! See all runnable option.',
    '    RustExpandMacro : Expanding macros!',
    '    RustOpenCargo : Goto The cargo.toml file in project',
    '    RustParentModule : Goto the parent module of that modules',
    '    RustJoinLines : Join the indented or entered lines',
    '    RustHoverActions : Code actions',
    '    RustMoveItemDown : move item at the cursor upward',
    '    RustMoveItemUp : move item at the cursor downward',
}

local function Create_Utils_Hints(bindkey)
    Help = nil

    local testlines = ui.text(RustHints).border('orange').build()

    Help = ui.win.CreatePopup(testlines, {
        enter = false,
        position = {
            col = '50%',
            row = '10',
        },
    })

    Nnoremap(bindkey, 'lua Help.toggle()')
end

-- keybind with context of rust lsp
-- use leader "r"
local function Rust_util_binder(rust_leader)
    -- keybind , command , option
    local key_command_pair = {
        use_arg = {
            { 'k', 'RustMoveItemUp' },
            { 'j', 'RustMoveItemDown' },
            config = {
                last_isarg = true,
                collector = function(func_arg)
                    local s, input = func_arg:lower(), ''
                    if s == 'up' then
                        input = 'true'
                    elseif s == 'down' then
                        input = 'false'
                    end
                    return input
                end,
            },
        },
        no_arg = {
            { 'i', 'RustToggleInlayHints' },
            { 'r', 'RustRunnables' },
            { 'p', 'RustParentModule' },
            { 'a', 'RustHoverActions' },
            -- {"h", "RustHoverRange"},
            { 'l', 'RustJoinLines' },
        },
        special = {
            { 'c', 'RustOpenCargo' },
            -- suffix define what the end of function name
            -- will be (all convert to lower case)
            config = {
                suffix = 'toml',
            },
        },
    }

    Create_command_key_pair(key_command_pair, create_rust_tool_cmd, rust_leader)
    Create_Utils_Hints(rust_leader .. 'h')
end

Rust_util_binder('<Space>r')

--if init lspinstall first we cannot use custom rust-analyzer

-- local config = require "lspinstall/util".extract_config("rust_analyzer")
-- config.default_config.cmd[1] = "./rust-analyzer"
--

local root_pattern = require('lspconfig').util.root_pattern
data = vim.fn.stdpath('data')
return {
    filetypes = { 'rust' },
    -- cmd = { data .. '/lsp_servers/rust/rust-analyzer' },
    root_dir = root_pattern('Cargo.toml', 'rust-project.json'),
    flags = { debounce_text_changes = 150 },
    on_attach = lsp.on_common_attach(false),
    -- settings = {
    --     ['rust-analyzer'] = {
    --         ['checkOnSave.enable'] = false,
    --         ['editor.formatOnSave'] = true,
    --     },
    -- },
}
