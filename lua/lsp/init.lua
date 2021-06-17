vim.cmd("luafile ~/.config/nvim/lua/lsp/nv-trouble.lua")
-- Global var wtih dtpath
DATA_PATH = vim.fn.stdpath('data')
-- define the sign !
local function diagnostic_definition(signs)
    if signs == nil
       then signs = {
           error_sign = "",
           warn = " ",
           hint = "",
           info = ""
        }
    end
    vim.fn.sign_define("LspDiagnosticsSignError",
                       {texthl = "LspDiagnosticsSignError", text = signs.error_sign, numhl = "LspDiagnosticsSignError"})
    vim.fn.sign_define("LspDiagnosticsSignWarning",
                       {texthl = "LspDiagnosticsSignWarning", text = signs.warn,numhl = "LspDiagnosticsSignWarning"})
    vim.fn.sign_define("LspDiagnosticsSignHint",
                       {texthl = "LspDiagnosticsSignHint", text = signs.hint,numhl = "LspDiagnosticsSignHint"})
    vim.fn.sign_define("LspDiagnosticsSignInformation",
                       {texthl = "LspDiagnosticsSignInformation", text = signs.info, numhl = "LspDiagnosticsSignInformation"})
    --print(vim.fn.bufname("%"))

end

-- apparently lsp sign broken for rust!
vim.g.ale_sign_error = ''
vim.g.ale_sign_warning = ' '

-- force native omnifunc to use lsp.omnifunc
vim.api.nvim_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

-- Mappings.
local opts = { noremap=true, silent=true }

local function build_mapper(leaders)
    print("Building mapper")
    local default = {'g','<space>','d'}
    if leaders == nil then
        leaders = {
            leader1 = default[1],
            leader2 = default[2],
            leader3 = default[3]
        }
    end
    --print(leaders.leader1)
    -- checking empty index !
    -- imp! len(leaders) == len(default)
    local i = 0
    for k,val in pairs(leaders) do
        if leaders == nil
            then leaders[k..i] = default[i]
        end
        i=i+1
    end

    local l1 = leaders.leader1
    local l2 = leaders.leader2
    local l3 = leaders.leader3

    return function (client,bufnr)

      --helpers
      local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
      local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

      -- g prefixes
      buf_set_keymap('n', l1 ..'D', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
      buf_set_keymap('n', l1 ..'d', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
      vim.api.nvim_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
      buf_set_keymap('n', l1 ..'i', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
      buf_set_keymap('n', l1 ..'r', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
      -- special binder
      buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
      buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
      -- leaders grouping 
      -- leader 2 relating to workspace
      buf_set_keymap('n', l2 ..'wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
      buf_set_keymap('n', l2 ..'wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
      buf_set_keymap('n', l2 ..'wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
      buf_set_keymap('n', l2 ..'D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
      -- rename functions or variables in the current buffer
      buf_set_keymap('n', l2 ..'rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
      -- good for bugfixing : 
      buf_set_keymap('n', l2 ..'e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
      -- list errors / hints in quickfix list!
      buf_set_keymap('n', l2 ..'q', '<cmd>lua vim.lsp.diagnostic.set_loclist({ severity_limit = "Warning","Error"  })<CR>', opts)
      -- go to the next diagnostic / error code block
      buf_set_keymap('n',l2 .. 'dn', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>',opts) 
      buf_set_keymap('n',l2 .. 'dp', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>',opts) 
      -- check if server could format the document
      if client.resolved_capabilities.document_highlight
        then buf_set_keymap("n", l2.."f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
      elseif client.resolved_capabilities.document_range_formatting
        then buf_set_keymap("n", l2.."f", "<cmd>lua vim.lsp.buf.range_formatting()<CR>", opts)
      end

      -- leader 3
      buf_set_keymap('n', '['..l3, '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
      buf_set_keymap('n', ']'..l3, '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)

    end
end

--vim.api.nvim_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
--auto formatting when server is loaded
local function documentHighlight(client, bufnr)
    -- Set autocommands conditional on server_capabilities
    if client.resolved_capabilities.document_highlight then
        vim.api.nvim_exec([[
      hi LspReferenceRead cterm=bold ctermbg=red guibg=#fff
      hi LspReferenceText cterm=bold ctermbg=red guibg=#fff
      hi LspReferenceWrite cterm=bold ctermbg=red guibg=#464646
      augroup lsp_document_highlight
        autocmd! * <buffer>
        autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
        autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
      augroup END
    ]], false)
    end
end

-- config that activates keymaps and enables snippet support
local function snippet_support()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  return capabilities
end 

local lsp_config = {}
-- t:table -> { client,bufnr,conf }
WorkingId = 0
local function attch_builder(t)
    local conf = t.config
    -- attachment 

    if t.mapper_builder == nil then -- non_null value
        --default options
        lsp_config.mapper = build_mapper(conf.leaders)
    else
        lsp_config.mapper = t.mapper_builder(conf.leaders)
    end

    if t.snippet == true
        then snippet_support()
    end
    local d_sign = t.diagnostic_signs 
    -- the args is necessary 
    local on_attach = function(client,bufnr)
        -- important func!
        diagnostic_definition(d_sign)
        documentHighlight(client,bufnr)
        lsp_config.mapper(client,bufnr)
        WorkingId = client.id
        require('utility').galaxyline.default_diagnostic()
        local sig_cfg = {
          bind = true, -- This is mandatory, otherwise border config won't get registered.
                       -- If you want to hook lspsaga or other signature handler, pls set to false
          doc_lines = 0, -- only show one line of comment set to 0 if you do not want API comments be shown
          hint_enable = true, -- virtual hint enable
          hint_prefix = "󰿉 ",  -- Panda for parameter
          hint_scheme = "String",
          use_lspsaga = false,  -- set to true if you want to use lspsaga popup
          handler_opts = {
            border = 'single'   -- double, single, shadow, none
          },
          --decorator = {"`", "`"}  -- or decorator = {"***", "***"}  decorator = {"**", "**"} see markdown help
        }
        -- show function signature when typing
        require("lsp_signature").on_attach(sig_cfg)
        local diag = vim.lsp.diagnostic.get("%",client.id)
        for i,x in pairs(diag) do 
            print(i,x)
        end

        MakeTrouble("<Space>")

        vim.lsp.diagnostic.set_signs(diag,"%",client.id,nil,{
            priority = 100,
            serverity = [[Error]]
        })
    end
    return on_attach
end

local function on_common_attach()

    -- disable coc avoid conflicting with lsp
    local v_t = {
        config = {
            leaders = nil,
            -- use default signs!
            diagnostic_signs = nil
        },
        snippet = true
    }
    return attch_builder(v_t) -- <-- func!
end

local lsp_module = {}
lsp_module.build_attacher = attch_builder
lsp_module.on_common_attach = on_common_attach

-- custom installer script
-- below is taken from the official repo!
--local function init_lspinstall()
--    require'lspinstall'.setup{}
--    -- this function available after calling
   function PRINTLSP()
       local servers = require'lspinstall'.installed_servers()
       for _, server in pairs(servers) do
           print(server)
       end
   end
--end
--lsp_module.init_lspinstall = init_lspinstall

-- Showing defaults
require'nvim-lightbulb'.update_lightbulb {
    sign = {
        enabled = true,
        -- Priority of the gutter sign
        priority = 30,
    },
    float = {
        enabled = false,
        -- Text to show in the popup float
        text = "💡",
        -- Available keys for window options:
        -- - height     of floating window
        -- - width      of floating window
        -- - wrap_at    character to wrap at for computing height
        -- - max_width  maximal width of floating window
        -- - max_height maximal height of floating window
        -- - pad_left   number of columns to pad contents at left
        -- - pad_right  number of columns to pad contents at right
        -- - pad_top    number of lines to pad contents at top
        -- - pad_bottom number of lines to pad contents at bottom
        -- - offset_x   x-axis offset of the floating window
        -- - offset_y   y-axis offset of the floating window
        -- - anchor     corner of float to place at the cursor (NW, NE, SW, SE)
        win_opts = {
            offset_x = 5,
            max_height = 20,
            max_width = 20,
            pad_left = 5,
            pad_right = 5,
            winblend = 76,
        },
    },
    virtual_text = {
        enabled = true,
        -- Text to show at virtual text
        text = "💡",
    }
}
vim.cmd [[autocmd CursorHold,CursorHoldI * lua require'nvim-lightbulb'.update_lightbulb()]]

vim.api.nvim_command('highlight LightBulbFloatWin guifg=#fff guibg=#111')
vim.api.nvim_command('highlight LightBulbVirtualText guifg=#135512 guibg=#193010')

--vim.fn.sign_define('LightBulbSign', { text = "💡", texthl = "" , linehl= "", numhl= "" })
return lsp_module
