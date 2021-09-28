FEL = {
    vcs = {},
    file = {},
    nvim = {}
}

local function ret(provider)
    return function()
        return provider
    end
end

-- schematic must support by library
FEL["vcs"]["get_branch"] = ret("git_branch")

FEL["vcs"]["get_workspace"] = function()
    return "git"
end

FEL["vcs"]["get_commit"] = function()
    local latest_commit = "git log -n 1 --pretty=format:" % H "  "
    return vim.cmd("!" .. latest_commit)
end

FEL["file"]["get_filename"] = ret("file_info")
FEL["file"]["get_filesize"] = ret("file_size")

FEL["nvim"]["get_line_position"] = ret("position")
FEL["nvim"]["get_page_position"] = ret("line_position")
FEL["nvim"]["getmode"] = import("data-access.adapters.custom").get_mode
FEL["nvim"]["get_line_diagnostics"] = function()
    return "Not"
end

return FEL
