--local provider = import("data-access.adapters.galaxyline.provider")
local provider = require("galaxyline")
_G.galaxyline_providers = {}
local galaxyline = _G.galaxyline_providers
for u, g in pairs(galaxyline) do
    print("gg", g, u)
end

local vcs = provider.vcs
local fileinfo = provider.fileinfo
-- local buffer = require("galaxyline.provider_buffer")
-- local extension = require("galaxyline.provider_extensions")
-- local whitespace = require("galaxyline.provider_whitespace")
-- local lspclient = require("galaxyline.provider_lsp")
local condition = provider.conditions

GL_DATA = {}
VCS = {}

VCS.get_workspace = function()
    if condition.check_git_workspace() then
        return "GIT"
    else
        return ""
    end
end

VCS.get_branch = function()
    return vcs.get_git_branch() or ""
end

VCS.get_commit = function()
    return "COMMIT"
end

FILE = {}

FILE.get_filesize = function()
    return fileinfo.get_file_size()
end

FILE.get_filename = function()
    local ficon = fileinfo.get_file_icon()
    local filename = fileinfo.get_current_file_name()
    return string.format("%s %s", ficon, filename)
end

NVIM = {}

NVIM.get_line_position = fileinfo.line_column
NVIM.get_page_position = fileinfo.current_line_percent
NVIM.line_diagnostics = function()
    return "Unavialable"
end

local o, _ = loadfile(BEDROCK_ROOT .. "data-access/adapters/custom.lua")

local custom = o()
NVIM.getmode = function()
    return custom.get_mode()
end
GL_DATA.vcs = VCS
GL_DATA.file = FILE
GL_DATA.nvim = NVIM

return GL_DATA
