local bedrock_prefix = "/bedrock/strata/arch"
require("utility.panel")
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
local root_pattern = require("lspconfig").util.root_pattern
local ra_path = LSP_REPO .. "rust/"
local lsp = access_core("lsp.init")

-- local capabilities = vim.lsp.protocol.make_client_capabilities()
-- capabilities = require("cmp_nvim_lsp").update_capabilities(capabilities)
-- Enable rust_analyzer

print("RA PATH", ra_path .. "rust-analyzer")

local lsp_installer_servers = require "nvim-lsp-installer.servers"

local ok, rust_analyzer = lsp_installer_servers.get_server("rust_analyzer")
if ok then
    if not rust_analyzer:is_installed() then
        rust_analyzer:install()
    end
end

local function goto_definition(split_cmd)
    local util = vim.lsp.util
    local log = require("vim.lsp.log")
    local api = vim.api
    local handler = function(_, method, result)
        if result == nil or vim.tbl_isempty(result) then
            local _ = log.info() and log.info(method, "No location found")
            return nil
        end
        if split_cmd then
            vim.cmd(split_cmd)
        end

        if vim.tbl_islist(result) then
            util.jump_to_location(result[1])
            if #result > 1 then
                util.set_qflist(util.locations_to_items(result))
                api.nvim_command("copen")
                api.nvim_command("wincmd p")
            end
        else
            util.jump_to_location(result)
        end
    end
    return handler
end
vim.lsp.handlers["textDocument/definition"] = goto_definition("split")

-- todo reconfig language server
local lsp_installer = require("nvim-lsp-installer")

nvim_lsp.rust.setup(
    {
        cmd = {ra_path .. "rust-analyzer"},
        -- cmd = {"rust-analyzer"},
        -- capabilities = capabilities,
        filetypes = {"rust"},
        root_dir = root_pattern("Cargo.toml", "rust-project.json"),
        on_attach = lsp.on_common_attach(),
        flags = {debounce_text_changes = 150},
        settings = {
            ["rust-analyzer"] = {
                ["checkOnSave.enable"] = false
            }
        }
    }
)

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

-- local inlay_opts = {
--     -- whether to show parameter hints with the inlay hints or not
--     -- default: true
--     show_parameter_hints = true,
--     -- prefix for parameter hints
--     parameter_hints_prefix = "<<",
--     -- prefix for all the other hints (type, chaining)
--     -- default: "=>"
--     other_hints_prefix = "=>"
-- }

-- -- set inlay hints
-- -- default on!
-- local toggler = 1
-- require("rust-tools.inlay_hints").set_inlay_hints(inlay_opts)
-- function ToggleInlay()
--     rust_tools.inlay_hints.toggle_inlay_hints(opts)
--     if toggler == 1 then
--         print("inlay ON!")
--     else
--         print("inlay OFF!")
--     end
-- end

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
            {"h", "RustHoverRange"},
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

    function Print_RustTool_help()
        local inlay_hints_dec = "InlayHints : is for showing type in virtual_text!"
        --local help_cmd =
        --    "\
        --    Commands :\
        --        RustSetInlayHints : Set InlayHints option!\
        --        RustDisableInlayHints : Disable InlayHints options\
        --        RustToggleInlayHints : Enable InlayHints options\
        --        RustRunnables : Good for testing! See all runnable option.\
        --        RustExpandMacro : Expanding macros!\
        --        RustOpenCargo : Goto The cargo.toml file in project\
        --        RustParentModule : Goto the parent module of that modules\
        --        RustJoinLines : Join the indented or entered lines\
        --        RustHoverActions : Code actions\
        --        RustMoveItemDown : move item at the cursor upward\
        --        RustMoveIthmUp : move item at the cursor downward\
        --    "

        local help_cmd = {
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
        Toggle_win(help_cmd)
        --vim.api.nvim_set_keymap("n","zo","<cmd>lua Toggle_win{Text}<CR>",{noremap = true})
    end

    Nnoremap(rust_leader .. "h", "<cmd>lua Print_RustTool_help()<CR>")
end

Rust_util_binder("<Space>r")
--Toggle_win({"hello boi"})

--if init lspinstall first we cannot use custom rust-analyzer

-- local config = require "lspinstall/util".extract_config("rust_analyzer")
-- config.default_config.cmd[1] = "./rust-analyzer"

nvim_lsp.rust_analyzer.setup({})
