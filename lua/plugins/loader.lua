-- a loader class
local loader = {}
loader.__index = loader

local is_profiling = false
vim.cmd([[packadd packer.nvim]])

function loader:bootstrap()
    local fn, execute = vim.fn, vim.api.nvim_command
    local install_path = '~/.local/share/nvim/site/pack/packer/start/packer.nvim'

    if fn.empty(fn.glob(install_path)) > 0 then
        execute('!git clone https://github.com/wbthomason/packer.nvim ' .. install_path)
        execute('packadd packer.nvim')
    end
end

local function make_packer_config(util)
    return {
        package_root = util.join_paths('~/.local/share/nvim/site/pack/'),
        compile_path = util.join_paths('~/.config/nvim', 'plugin', 'packer_compiled.lua'),
        git = {
            clone_timeout = 300,
            default_url_format = 'https://github.com/%s',
        },
        display = {
            keybindings = {
                -- Keybindings for the display window
                quit = 'q',
                toggle_info = '<CR>',
                diff = 'd',
                prompt_revert = 'r',
            },
            working_sym = '',
            error_sym = '',
            prompt_border = 'double',
            open_fn = function()
                return util.float({ border = 'rounded' })
            end,
        },
        profile = {
            enable = is_profiling,
            threshold = 1,
        },
    }
end

function loader:load_packages(packages)
    local function load(use, log)
        local logger = function(txt)
            if not log or log == nil then
                return nil
            end
            print(txt)
        end

        local count = 0
        for _, package in pairs(packages) do
            local package_name = package

            if type(package) == 'table' then
                package_name = package[1]
            end
            logger(package_name .. ' is loading!')
            use(package)
            count = count + 1
        end
        vim.notify('Total packages loaded:' .. count .. 'packages')
    end

    if self.packer == nil then
        error('Please initialize the loader instance before proceed!', 1)
        return
    end
    self.packer.reset()
    self.packer.startup(function(use)
        -- use({ 'luaunit' })
        -- use_rocks({ 'luaunit' })
        load(use, false)
    end)
end

function loader:init_loader()
    local ld = {}
    local packer_ok, packer = pcall(require, 'packer')

    -- packer.use_rocks({})
    -- packer.install_commands()
    if not packer_ok then
        return
    end

    setmetatable(ld, loader)
    local util = require('packer.util')
    -- nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'
    -- packer.use+use_rocks
    local cfg = make_packer_config(util)
    -- packer.luarocks.install_commands()
    packer.init(cfg)

    ld.packer = packer

    return ld
end

return loader
