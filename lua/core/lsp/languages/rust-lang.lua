-- local _bedrock_prefix = "/bedrock/strata/arch"
local ui = access_system("ui.init")
--root_dir = root_pattern("Cargo.toml", "rust-project.json"),
--cmd = { "strat -u void ~/.cargo/bin/rust-analyzer" },
--todo : fix on attach func
--and figure out why it doesn't autoCOMPLETE
--reconfigure the rustc in fish conf and remap its path
--/bedrock/strata/arch/usr/bin/rustc

local nvim_lsp = require("lspconfig")
--[[
-- FIX rust_analyzer confliction with lspinstall:
-- go to stdpath("")/nvim-lspinstall/lua/lspinstall/servers/rust.lua
-- comment out these lines :
    -- require'lspconfig/configs'.rust_analyzer = nil -- this line cause RA to go empty
    -- config.default_config.cmd[1] = "./rust-analyzer"
--
--]]
-- local capabilities = vim.lsp.protocol.make_client_capabilities()
-- capabilities = require("cmp_nvim_lsp").update_capabilities(capabilities)
-- Enable rust_analyzer

-- local lsp_installer_servers = require "nvim-lsp-installer.servers"

-- local ok, rust_analyzer = lsp_installer_servers.get_server("rust_analyzer")
-- if ok then
--     if not rust_analyzer:is_installed() then
--         rust_analyzer:install()
--     end
-- end

-- todo reconfig language server

DONE = false

Create_augroup(
    {
        {
            "BufEnter,BufRead",
            "*.toml",
            "lua require('cmp').setup.buffer { sources = { { name = 'crates' } } }"
        }
    },
    "lazy_cmp_crates_buffer"
)
-- Enable diagnostics
vim.lsp.handlers["textDocument/publishDiagnostics"] =
    vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics,
    {
        -- Enable underline, use default values
        underline = true,
        -- Enable virtual text, override spacing to 4
        virtual_text = {
            spacing = 4
        },
        -- Use a function to dynamically turn signs off
        -- and on, using buffer local variables
        signs = function(bufnr, client_id)
            print("bfnr", bufnr, client_id)
            return true
            --return vim.bo[bufnr].show_signs == false
        end,
        -- Disable a feature
        update_in_insert = false
    }
)
--{{{{{{}}}}}}
--vim.cmd("set completeopt=menuone,noinsert,noselect")

local opts = {
    tools = {
        --show things such as tests / mod
        runnables = {
            use_telescope = true
            -- rest of the opts are forwarded to telescope
        }
    }
}

local rust_tools = require("rust-tools")
rust_tools.setup(opts)

local inlay_opts = {
    -- whether to show parameter hints with the inlay hints or not
    -- default: true
    show_parameter_hints = true,
    -- prefix for parameter hints
    parameter_hints_prefix = "<<",
    -- prefix for all the other hints (type, chaining)
    -- default: "=>"
    other_hints_prefix = "=>"
}

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
        last = option["use_last"] or false
    end
    local res = Command_to_func_name(cmds, option)
    for i, com in pairs(res) do
        local func_arg, input = com[2] or "", ""
        if func_arg and last then
            input = option["collector"](func_arg)
        end

        local modname = AllTrim("rust-tools." .. com[1])
        local func = "require(" .. "'" .. modname .. "'" .. ")." .. com[1] .. "(" .. input .. ")"
        Create_command(cmds[i], func)
    end
end

local inlay_hints_dec = "InlayHints : is for showing type in virtual_text!"
RustHints = {
    inlay_hints_dec,
    "Commands :",
    "    RustSetInlayHints : Set InlayHints option!",
    "    RustDisableInlayHints : Disable InlayHints options",
    "    RustToggleInlayHints : Enable InlayHints options",
    "    RustRunnables : Good for testing! See all runnable option.",
    "    RustExpandMacro : Expanding macros!",
    "    RustOpenCargo : Goto The cargo.toml file in project",
    "    RustParentModule : Goto the parent module of that modules",
    "    RustJoinLines : Join the indented or entered lines",
    "    RustHoverActions : Code actions",
    "    RustMoveItemDown : move item at the cursor upward",
    "    RustMoveItemUp : move item at the cursor downward"
}

function Create_Utils_Hints(bindkey)
    Help = nil

    local testlines = ui.text(RustHints).border("orange").build()

    Help =
        ui.win.CreatePopup(
        testlines,
        {
            enter = false,
            position = {
                col = "50%",
                row = "10"
            }
        }
    )

    Nnoremap(bindkey, "lua Help.toggle()")
end

-- keybind with context of rust lsp
-- use leader "r"
function Rust_util_binder(rust_leader)
    -- keybind , command , option
    local key_command_pair = {
        use_arg = {
            {"k", "RustMoveItemUp"},
            {"j", "RustMoveItemDown"},
            config = {
                last_isarg = true,
                collector = function(func_arg)
                    local s, input = func_arg:lower(), ""
                    if s == "up" then
                        input = "true"
                    elseif s == "down" then
                        input = "false"
                    end
                    return input
                end
            }
        },
        no_arg = {
            {"i", "RustToggleInlayHints"},
            {"r", "RustRunnables"},
            {"p", "RustParentModule"},
            {"a", "RustHoverActions"},
            -- {"h", "RustHoverRange"},
            {"l", "RustJoinLines"}
        },
        special = {
            {"c", "RustOpenCargo"},
            -- suffix define what the end of function name
            -- will be (all convert to lower case)
            config = {
                suffix = "toml"
            }
        }
    }

    Create_command_key_pair(key_command_pair, create_rust_tool_cmd, rust_leader)
    Create_Utils_Hints(rust_leader .. "h")
end

Rust_util_binder("<Space>r")

--if init lspinstall first we cannot use custom rust-analyzer

-- local config = require "lspinstall/util".extract_config("rust_analyzer")
-- config.default_config.cmd[1] = "./rust-analyzer"
--

local root_pattern = require("lspconfig").util.root_pattern
RustProvider = {
    filetypes = {"rust"},
    root_dir = root_pattern("Cargo.toml", "rust-project.json"),
    flags = {debounce_text_changes = 150},
    settings = {
        ["rust-analyzer"] = {
            ["checkOnSave.enable"] = false
        }
    }
}
