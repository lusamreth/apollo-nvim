local bedrock_prefix = "/bedrock/strata/arch"
require("utility.render")
--root_dir = root_pattern("Cargo.toml", "rust-project.json"),
--cmd = { "strat -u void ~/.cargo/bin/rust-analyzer" },
--todo : fix on attach func
--and figure out why it doesn't autoCOMPLETE
--reconfigure the rustc in fish conf and remap its path
--/bedrock/strata/arch/usr/bin/rustc

--local capabilities = vim.lsp.protocol.make_client_capabilities()
--capabilities.textDocument.completion.completionItem.snippetSupport = true
--capabilities.textDocument.completion.completionItem.resolveSupport = {
--  properties = {
--    'documentation',
--    'detail',
--    'additionalTextEdits',
--  }
--}

local nvim_lsp = require('lspconfig')
--[[
-- FIX rust_analyzer confliction with lspinstall:
-- go to stdpath("")/nvim-lspinstall/lua/lspinstall/servers/rust.lua
-- comment out these lines :
    -- require'lspconfig/configs'.rust_analyzer = nil -- this line cause RA to go empty
    -- config.default_config.cmd[1] = "./rust-analyzer"
--
--]]

local root_pattern = require("lspconfig").util.root_pattern
-- Enable rust_analyzer
nvim_lsp.rust.setup({
    cmd = {"rust-analyzer"},
    filetypes = {"rust"},
    root_dir = root_pattern("Cargo.toml", "rust-project.json"),
    on_attach = require'lsp'.on_common_attach(),
    settings = {
        ["rust-analyzer"] = {
            ["checkOnSave.enable"] = false,
        }
    }
})

-- Enable diagnostics
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
   vim.lsp.diagnostic.on_publish_diagnostics, {
     -- Enable underline, use default values
    underline = true,
    -- Enable virtual text, override spacing to 4
    virtual_text = {
        spacing = 4,
    },
    -- Use a function to dynamically turn signs off
    -- and on, using buffer local variables
    signs = function(bufnr, client_id)
        print("bfnr",bufnr,client_id)
        return true
        --return vim.bo[bufnr].show_signs == false
        end,
    -- Disable a feature
    update_in_insert = false,
})
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


local rust_tools = require('rust-tools')
rust_tools.setup(opts)

local inlay_opts = {
    -- whether to show parameter hints with the inlay hints or not
    -- default: true
    show_parameter_hints = true,

    -- prefix for parameter hints
    parameter_hints_prefix = "<<",

    -- prefix for all the other hints (type, chaining)
    -- default: "=>"
    other_hints_prefix  = "=>",
}

-- set inlay hints
-- default on!
local toggler = 1
require('rust-tools.inlay_hints').set_inlay_hints(inlay_opts)
function ToggleInlay()
    rust_tools.inlay_hints.toggle_inlay_hints(opts)
    if toggler == 1 then
        print("inlay ON!")
    else
        print("inlay OFF!")
    end
end

function Rust_util_binder(rust_leader)
    local opt = {noremap=true,silent=true}
    --vim.api.nvim
    vim.api.nvim_set_keymap("n",rust_leader.."i","<cmd>lua ToggleInlay()<CR>",opt)
    vim.api.nvim_set_keymap("n",rust_leader.."r","<cmd>RustRunnables<CR>",opt)
    vim.api.nvim_set_keymap("n",rust_leader.."c","<cmd>RustOpenCargo<CR>",opt)
    vim.api.nvim_set_keymap("n",rust_leader.."k","<cmd>RustMoveItemUp<CR>",opt)
    vim.api.nvim_set_keymap("n",rust_leader.."j","<cmd>RustMoveDown<CR>",opt)
    vim.api.nvim_set_keymap("n",rust_leader.."j","<cmd>RustMoveDown<CR>",opt)
    vim.api.nvim_set_keymap("n",rust_leader.."p","<cmd>RustParentModule<CR>",opt)

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

        local help_cmd =
        {
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
            "    RustMoveIthmUp : move item at the cursor downward"
        }
        Toggle_win(help_cmd)
        --vim.api.nvim_set_keymap("n","zo","<cmd>lua Toggle_win{Text}<CR>",{noremap = true})
    end

    vim.api.nvim_set_keymap("n",rust_leader.."h","<cmd>lua Print_RustTool_help()<CR>",opt)
    vim.api.nvim_set_keymap("n","<C-a>","<cmd>lua require'rust-tools.hover_actions'.hover_actions()<CR>",opt)
end

Rust_util_binder("<Space>r")
--Toggle_win({"hello boi"})

--if init lspinstall first we cannot use custom rust-analyzer
