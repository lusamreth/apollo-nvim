vim.g.symbols_outline = {
    highlight_hovered_item = true,
    show_guides = true,
    auto_preview = true, -- experimental
    position = "left",
    keymaps = {
        close = "<Esc>",
        goto_location = "<Cr>",
        focus_location = "o",
        hover_symbol = "<C-space>",
        rename_symbol = "r",
        code_actions = "a"
    },
    lsp_blacklist = {}
}

-- still buggy
--Nnoremap(",o","SymbolsOutline",{silent = true})

vim.g.indent_blankline_enabled = true
vim.g.indentLine_fileTypeExclude = {"dashboard"}

-- http://lua-users.org/wiki/FileInputOutput

-- see if the file exists
function file_exists(file)
    local f = io.open(file, "rb")
    if f then
        f:close()
    end
    return f ~= nil
end

-- get all lines from a file, returns an empty
-- list/table if the file does not exist
function lines_from(file)
    if not file_exists(file) then
        return {}
    end
    lines = {}
    for line in io.lines(file) do
        lines[#lines + 1] = line
    end
    return lines
end

-- tests the functions above
local file = "/home/lusamreth/diablo-head.txt"
local lines = lines_from(file)

require("utility.var")
--vim.g.dashboard_custom_header = lines


local home = os.getenv('HOME')
local db = require('dashboard')
--
db.preview_file_height = 11
db.preview_file_width = 70

db.custom_header = PUFFYBOI
-- db.preview_command = 'chafa'

db.custom_center = {
  {icon = '  ',
  desc = 'Recently latest session                  ',
  shortcut = 'SPC s l',
  action ='SessionLoad'},
  {icon = '  ',
  desc = 'Recently opened files                   ',
  action =  'DashboardFindHistory',
  shortcut = 'SPC f h'},
  {icon = '  ',
  desc = 'Find  File                              ',
  action = 'Telescope find_files find_command=rg,--hidden,--files',
  shortcut = 'SPC f f'},
  {icon = '  ',
  desc ='File Browser                            ',
  action =  'Telescope file_browser',
  shortcut = 'SPC f b'},
  {icon = '  ',
  desc = 'Find  word                              ',
  action = 'Telescope live_grep',
  shortcut = 'SPC f w'},
  {icon = '  ',
  desc = 'Open Personal dotfiles                  ',
  action = 'Telescope dotfiles path=' .. home ..'/.dotfiles',
  shortcut = 'SPC f d'},
}



-- The setup config table shows all available config options with their default values:
require("presence"):setup(
    {
        -- General options
        auto_update = true, -- Update activity based on autocmd events (if `false`, map or manually execute `:lua package.loaded.presence:update()`)
        neovim_image_text = "Neovim >>>>>> Visual studio", -- Text displayed when hovered over the Neovim image
        main_image = "neovim", -- Main image display (either "neovim" or "file")
        client_id = "793271441293967371", -- Use your own Discord application client id (not recommended)
        log_level = nil, -- Log messages at or above this level (one of the following: "debug", "info", "warn", "error")
        debounce_timeout = 10, -- Number of seconds to debounce events (or calls to `:lua package.loaded.presence:update(<filename>, true)`)
        enable_line_number = false, -- Displays the current line number instead of the current project
        -- Rich Presence text options
        editing_text = "Current Programing Working on %s", -- Format string rendered when an editable file is loaded in the buffer
        file_explorer_text = "Browsing %s", -- Format string rendered when browsing a file explorer
        git_commit_text = "Committing changes", -- Format string rendered when commiting changes in git
        plugin_manager_text = "Managing plugins", -- Format string rendered when managing plugins
        reading_text = "Reading %s", -- Format string rendered when a read-only or unmodifiable file is loaded in the buffer
        workspace_text = "Working on %s", -- Workspace format string (either string or function(git_project_name: string|nil, buffer: string): string)
        line_number_text = "Line %s out of %s" -- Line number format string (for when enable_line_number is set to true)
    }
)
