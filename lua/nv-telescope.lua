
--require('telescope').load_extension('media_files')
local actions = require('telescope.actions')

require('telescope').setup{
    defaults = {
       prompt_prefix = "Search?",
       prompt_position = "top",
       initial_mode = "insert",
       file_sorter = require'telescope.sorters'.get_fzy_sorter,
       file_previewer = require'telescope.previewers'.vim_buffer_cat.new,
       grep_previewer = require'telescope.previewers'.vim_buffer_vimgrep.new,
       qflist_previewer = require'telescope.previewers'.vim_buffer_qflist.new,
       layout_strategy = "vertical",
       winblend = 1,
       width = 0.65,
       mappings = {
          -- insert mode!
          i = {
            -- To disable a keymap, put [map] = false
            -- So, to not map "<C-n>", just put
            ["<C-x>"] = false,
        
            -- Otherwise, just set the mapping to the function that you want it to be.
            ["<C-i>"] = actions.move_selection_next,
            -- Add up multiple actions
            -- You can perform as many actions in a row as you like
            ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
            ["<esc>"] = actions.close
          },
          -- normal mode!
          n = {
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous
          },
       },
        borderchars = { '─', '│', '─', '│', '*', '*', '*', '*' },
       color_devicons = true,
       extensions = {
        --media_files = {
        --    -- filetypes whitelist
        --    -- defaults to {"png", "jpg", "mp4", "webm", "pdf"}
        --    filetypes = {"png", "webp", "jpg", "jpeg"},
        --    find_cmd = "rg" -- find command (defaults to `fd`)
        --}

       }

    }
}

