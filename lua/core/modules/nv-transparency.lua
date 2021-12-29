-- this provider finer control than highlight guibg=none!
-- to make thing transparent also require picom or compton
-- compositor

require("transparent").setup(
    {
        enable = true, -- boolean: enable transparent
        extra_groups = {
            -- table/string: additional groups that should be clear
            -- In particular, when you set it to 'all', that means all avaliable groups
            -- example of akinsho/nvim-bufferline.lua
            "BufferLineTabClose",
            "BufferlineBufferSelected",
            "BufferLineFill",
            "BufferLineBackground",
            "BufferLineSeparator",
            "NvimTree",
            "NvimTreeFolder",
            "BufferLineIndicatorSelected"
        },
        exclude = {} -- table: groups you don't want to clear
    }
)

vim.cmd("TransparentEnable")
