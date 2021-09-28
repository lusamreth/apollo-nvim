require("utility")
local colors = require("galaxyline.colors").default

local yellow = "#ECBE7B"
local cyan = "#008080"
local darkblue = "#081633"
local magenta = "#c678dd"
local blue = "#51afef"
local red = "#ec5f67"
local orange = "#e78a4e"
--local red = "#DF8890"
--local bg = "#282a50"
local nord = "#81A1C9"
--local nord = "#111"
local white = "#ffffff"

local galaxyline = require("galaxyline")
local fileinfo = require("galaxyline.provider_fileinfo")
-- local buffer = require('galaxyline.provider_buffer')
local vcs = require("galaxyline.provider_vcs")
local function generate_padding(len, dir)
    local sym
    if dir == "left" or dir == "l" then
        sym = "+"
        return string.rep(sym, len) .. " "
    end

    if dir == nil or dir == "right" then
        -- actually 1 char , escape does not count
        sym = "-"
        return "  " .. string.rep(sym, len)
    end
end
-- The section composes of array containing
-- prop that define the text
galaxyline.short_line_list = {
    "LuaTree",
    "NvimTree",
    "vista",
    "dbui",
    "startify",
    "term",
    "dashboard",
    "Trouble",
    "qf",
    "toggleterm",
    "nerdtree"
}

local gls = galaxyline.section
gls.short_line_left[1] = {
    ftype = {
        provider = "FileTypeName",
        highlight = {orange, blue},
        separator = "",
        separator_highlight = {"NONE", fg}
    }
}

gls.short_line_right[2] = {
    fd = {
        provider = fileinfo.current_line_percent,
        highlight = {orange, cyan},
        separator = " ",
        separator_highlight = {"NONE", fg}
    }
}

gls.short_line_right[5] = {BufferIcon = {provider = "BufferIcon", highlight = {yellow, fg}}}
-- taken from evilline.lua --

--local function get_coc_lsp()
--  -- call status() func from coc plugin!
--  local status = vim.fn['coc#status']()
--  if not status or status == '' then
--      return ''
--  end
--  return lsp_status(status)
--end

gls.left[4] = {
    FileSize = {
        provider = "FileSize",
        condition = function()
            if vim.fn.empty(vim.fn.expand("%:t")) ~= 1 then
                return true
            end
            return false
        end,
        icon = "  ",
        highlight = {white, cyan}
    }
}
gls.left[0] = {
    PaddingLeft = {
        provider = function()
            return generate_padding(0, "left")
        end,
        highlight = {yellow, fg}
    }
}

gls.left[5] = {
    rightRounded = {
        provider = function()
            return ""
        end,
        highlight = {cyan, white}
    }
}
local condition = require("galaxyline.condition")

gls.left[1] = {
    leftRounded = {
        provider = function()
            return ""
        end,
        highlight = {nord, fg},
        separator = "",
        seperator_highlight = {nord, nord}
    }
}

gls.left[2] = {
    statusIcon = {
        provider = function()
            return "  "
        end,
        highlight = {red, nord}
        --separator = " ",
        --separator_highlight = {bg, nord}
    }
}

gls.left[3] = {
    filename = {
        provider = function()
            local fileIcon = fileinfo.get_file_icon()
            local fileName = fileinfo.get_current_file_name()
            return " f:" .. fileIcon .. all_trim(fileName) .. " "
        end,
        --condition = condition.buffer_not_empty,
        highlight = {darkblue, nord},
        separator = " ",
        separator_highlight = {nord}
    }
}
--local str = "ab ,cd/ef sdjaskd,sdjaskdjas,sdaskd"
--print_r(split(str,","))
--local z = split("x:123123",":")
--print(z[0],z[1])

gls.right[0] = {
    DiffAdd = {
        provider = "DiffAdd",
        condition = condition.hide_in_width,
        icon = "  ",
        highlight = {yellow, orange}
    }
}
gls.right[1] = {
    GitIcon = {
        provider = function()
            return "  "
        end,
        condition = require("galaxyline.provider_vcs").check_git_workspace,
        highlight = {orange, fg},
        separator = "git"
    }
}

gls.right[2] = {
    GitBranch = {
        provider = function()
            local gitbranch = vcs.get_git_branch()
            local _g = string.format("%s ", gitbranch)
            return gitbranch
        end,
        condition = require("galaxyline.provider_vcs").check_git_workspace,
        highlight = {white, fg},
        seperator = " ",
        separator_highlight = {white, fg}
    }
}

gls.right[3] = {
    left_rightround = {
        provider = function()
            return ""
        end,
        highlight = {red, white}
    }
}

gls.right[4] = {
    ViMode = {
        provider = function()
            local alias = {
                n = "NORMAL",
                i = "INSERT",
                c = "COMMAND",
                V = "VISUAL",
                [""] = "VISUAL",
                v = "VISUAL",
                R = "REPLACE"
            }
            --vim.fn.mode() -> abbreviation
            --such as 'n' for 'normal'
            return alias[vim.fn.mode()] .. " "
        end,
        highlight = {fg, red},
        seperator = "",
        seperator_highlight = {white, cyan}
    }
}

gls.right[6] = {
    rightRounded = {
        provider = function()
            return ""
        end,
        separator = "",
        seperator_highlight = {white, cyan},
        highlight = {white, cyan}
    }
}

gls.right[5] = {
    PerCent = {
        provider = "LinePercent",
        separator = " ",
        separator_highlight = {white, cyan},
        highlight = {white, cyan}
    }
}

gls.right[7] = {
    PaddingRight = {
        provider = function()
            return generate_padding(0, "right")
        end,
        highlight = {yellow, fg}
    }
}
--   --
