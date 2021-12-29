require("utility.var")
local ui = access_system("ui.init")
local api = vim.api
local if_nil = vim.F.if_nil
-- todo: dechipher this algorithm
vim.lsp.diagnostic.show_line_diagnostics = function(opts, bufnr, line_nr, client_id)
    opts = opts or {}
    opts.severity_sort = if_nil(opts.severity_sort, true)

    local show_header = if_nil(opts.show_header, true)

    bufnr = bufnr or 0
    line_nr = line_nr or (vim.api.nvim_win_get_cursor(0)[1] - 1)

    local lines = {}
    local highlights = {}
    if show_header then
        table.insert(lines, "DG:Diagnostics:")
        table.insert(highlights, {0, "Bold"})
    end

    local line_diagnostics = vim.lsp.diagnostic.get_line_diagnostics(bufnr, line_nr, opts, client_id)
    if vim.tbl_isempty(line_diagnostics) then
        return
    end

    for i, diagnostic in ipairs(line_diagnostics) do
        local prefix = string.format("%d. ", i)
        local hiname = vim.lsp.diagnostic._get_floating_severity_highlight_name(diagnostic.severity)
        assert(hiname, "unknown severity: " .. tostring(diagnostic.severity))

        local message_lines = vim.split(diagnostic.message, "\n", true)

        local columns = api.nvim_get_option("columns")
        local popup_max_width = math.floor(columns - (columns * 2 / 10))
        local stripped_max_width = {}
        print(popup_max_width)

        for _, line in ipairs(message_lines) do
            local len = line:len()
            -- if the content line overflow! readjust
            if len > popup_max_width then
                for j = 1, math.ceil(len / popup_max_width) do
                    --numbering system
                    table.insert(
                        stripped_max_width,
                        string.sub(line, 1 + ((j - 1) * popup_max_width), (j * popup_max_width))
                    )
                end
            else
                table.insert(stripped_max_width, line)
            end
        end

        message_lines = stripped_max_width

        table.insert(lines, prefix .. message_lines[1])
        table.insert(highlights, {#prefix + 1, hiname})
        for j = 2, #message_lines do
            table.insert(lines, message_lines[j])
            table.insert(highlights, {2, hiname})
        end
    end

    local max_length = 0

    for _, line in ipairs(lines) do
        print(line)
        local len = line:len()
        if len > max_length then
            max_length = len
        end
    end

    for i, line in ipairs(lines) do
        local len = line:len()
        -- start inserting vertial border between each line!
        lines[i] =
            string.format("%s%s%s%s", BORDERHORIZONTAL, line, string.rep(" ", max_length - len), BORDERHORIZONTAL)
    end

    table.insert(lines, 1, BORDERTOPLEFT .. string.rep(BORDERVERTICAL, max_length) .. BORDERTOPRIGHT)
    table.insert(lines, BORDERBOTLEFT .. string.rep(BORDERVERTICAL, max_length) .. BORDERBOTRIGHT)

    local popup_bufnr, winnr = vim.lsp.util.open_floating_preview(lines, "plaintext")
    for i, hi in ipairs(highlights) do
        local prefixlen, hiname = unpack(hi)
        -- Start highlight after the prefix
        api.nvim_buf_add_highlight(popup_bufnr, -1, hiname, i, prefixlen + 2, max_length + 4)
    end

    return popup_bufnr, winnr
end

vim.lsp.diagnostic.show_line_diagnostics = function(opts, bufnr, line_nr, client_id)
    local line_diagnostics = vim.lsp.diagnostic.get_line_diagnostics(bufnr, line_nr, opts, client_id)
    if vim.tbl_isempty(line_diagnostics) then
        return
    end

    opts = opts or {}
    local lines = {}
    local show_header = if_nil(opts.show_header, true)
    local highlights = {}

    if show_header then
        table.insert(lines, "DG:Diagnostics:")
        table.insert(highlights, {0, "Bold"})
    end

    local txt_obj
    local severity
    for i, line_diagnostic in pairs(line_diagnostics) do
        local prefix = string.format("*%d.", i)
        local txt = string.format("%s %s", prefix, line_diagnostic["message"])
        print("DIAGNOA", line_diagnostic.severity)
        severity = line_diagnostic.severity
        -- if #txt > 40 then
        --     txt = Splitstr(txt, " ")
        -- end
        local hiname = vim.lsp.diagnostic._get_floating_severity_highlight_name(line_diagnostic.severity)
        assert(hiname, "unknown severity: " .. tostring(line_diagnostic.severity))
        -- has the option to include prefix highlight or not !
        table.insert(highlights, {0, hiname})
        table.insert(lines, txt)
        txt_obj = ui.text(lines).border().build()
    end

    local popup_bufnr, winnr = vim.lsp.util.open_floating_preview(txt_obj["lines"], "plaintext")
    local severity_color = {
        "red",
        "yellow",
        "purple",
        "blue"
    }
    MakeHighlighBorder(txt_obj, severity_color[severity])(popup_bufnr)

    -- to apply hightlight require col(start) and col(end)
    for i, hi in ipairs(highlights) do
        local prefix, hiname = 0, nil
        if type(hi) == "table" then
            prefix, hiname = unpack(hi)
        else
            hiname = hi
        end
        -- Start highlight after the prefix
        api.nvim_buf_add_highlight(popup_bufnr, -1, hiname, i, prefix + 4, txt_obj["property"]["whole_length"] + 4)
    end
    return popup_bufnr, winnr
end

-- BRUH MOMENT !
-- Response from lsp (line_diagnostics) [array]:
-- { {
--     code = "unused-local",
--     message = "Unused local `lspconfig`.",
--     range = {
--       end = {
--         character = 15,
--         line = 103
--       },
--       start = {
--         character = 6,
--         line = 103
--       }
--     },
--     severity = 4,
--     source = "Lua Diagnostics.",
--     tags = { 1 }
--   } }
-- reverse engineering the code

local lspconfig = require("lspconfig")

-- lspconfig.util.default_config =
--     vim.tbl_extend(
--     "force",
--     lspconfig.util.default_config,
--     {
--         autostart = false,
--         handlers = {
--             ["window/logMessage"] = function(err, method, params, client_id)
--                 if params and params.type <= vim.lsp.protocol.MessageType.Log then
--                     vim.lsp.handlers["window/logMessage"](err, method, params, client_id)
--                 end
--             end,
--             ["window/showMessage"] = function(err, method, params, client_id)
--                 if params and params.type <= vim.lsp.protocol.MessageType.Warning.Error then
--                     vim.lsp.handlers["window/showMessage"](err, method, params, client_id)
--                 end
--             end
--         }
--     }
-- )
