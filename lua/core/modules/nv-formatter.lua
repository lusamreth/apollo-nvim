local Job = require "plenary.job"

local loop = vim.loop

SPAWN = function(command, args, onread, onexit)
    local stdout = loop.new_pipe(false) -- create file descriptor for stdout
    local stderr = loop.new_pipe(false) -- create file descriptor for stdout
    Handle =
        loop.spawn(
        command,
        {
            args = args,
            stdio = {stdout, stderr}
        },
        vim.schedule_wrap(
            function()
                stdout:read_stop()
                stderr:read_stop()
                stdout:close()
                stderr:close()
                -- function exec before closing
                onexit()
                Handle:close()
            end
        )
    )
    loop.read_start(stdout, onread) -- TODO implement onread handler
    loop.read_start(stderr, onread)
end

local function write_to_buf(data, bufnr)
    local new_lines
    if type(data) == "table" then
        new_lines = data
    else
        new_lines = vim.split(data, "\n")
    end

    -- check for errors
    if string.find(new_lines[#new_lines], "^# exit %d+") then
        error(string.format("failed to format with prettier: %s", data))
    end

    -- write contents
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, new_lines)
end

function ManualFormat(cmd, args)
    local res = {}
    local function send_to_res(err, data)
        if err then
            error("Formatter got error!", error)
        end

        table.insert(res, data)
    end

    local function retrieve_to_buf()
        local bufnr = vim.api.nvim_get_current_buf()
        for i, r in pairs(res) do
            res[i] = AllTrim(r)
        end
        write_to_buf(res[1], bufnr)
        vim.cmd("w")
    end
    SPAWN(cmd, args, send_to_res, retrieve_to_buf)
end

local filetype_config = {
    python = {
        ext = "py",
        fmtconfig = {
            exe = "python3 -m yapf",
            args = {"--style", "google"},
            stdin = true
        }
    },
    json = {
        manual = true,
        fmtconfig = {
            exe = "jq",
            args = {"."},
            stdin = false
        }
    },
    xml = {
        manual = true,
        fmtconfig = {
            exe = "xmllint",
            args = {
                "--format"
            },
            stdin = false
        }
    },
    javascript = {
        ext = "js",
        fmtconfig = {
            exe = "prettier",
            args = {
                "--stdin-filepath",
                vim.api.nvim_buf_get_name(0),
                "--single-quote"
            },
            stdin = true
        }
    },
    rust = {
        ext = "rs",
        -- Rustfmt
        fmtconfig = {exe = "rustfmt", args = {"--edition=2018", "--emit=stdout"}, stdin = true}
    },
    lua = {
        -- luafmt
        fmtconfig = {
            exe = "luafmt",
            args = {"--indent-count", 4, "--stdin"},
            stdin = true
        }
    }
}

local ftconfig = {}
local extensions = {
    manual = {},
    normal = {}
}

local function create_format_func(config)
    return {
        function()
            return config
        end
    }
end

local function insert_ext(config, val)
    if config["manual"] then
        table.insert(extensions["manual"], val)
    else
        table.insert(extensions["normal"], val)
    end
end

FormatAutoCmd = {}
import("utility.init")
import("utility.binding")
function MakeFmtFunc(config)
    local c = config["fmtconfig"]
    vim.validate(
        {
            {
                c["exe"],
                "s"
            },
            {
                c["args"],
                "t"
            }
        }
    )

    local exec, arg = c["exe"], c["args"]
    local last = #arg + 1

    return function()
        local currentbuf = vim.api.nvim_buf_get_name(0)
        -- will litherally pass the string of current buffer content
        -- to process formatting
        if config["RequireRawInput"] then
            local bufnr = vim.api.nvim_get_current_buf()
            currentbuf = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
            local total_line = ""
            for _, line in pairs(currentbuf) do
                total_line = total_line .. line
            end
            currentbuf = total_line
        end

        arg[last] = currentbuf
        ManualFormat(exec, arg)
    end
end

for name, config in pairs(filetype_config) do
    local ext
    if config["ext"] == nil then
        ext = name
    else
        ext = config["ext"]
    end
    insert_ext(config, ext)

    -- store extension as ref
    if config["manual"] then
        print("EXT ++>", ext)
        FormatAutoCmd[ext] = MakeFmtFunc(config)
    end
    -- stash it into nvim.formatter
    ftconfig[name] = create_format_func(config["fmtconfig"])
end

StringExt = {}

-- use to create manual augroup
local function init_manual(MnExt, hook)
    local res = {}
    if #MnExt == 0 then
        return
    end

    for i, ext in pairs(MnExt) do
        local s = string.format("lua FormatAutoCmd['%s']()", ext)
        res[i] = {hook, "*." .. ext, s}
    end

    return res
end

-- exts(array) -> string
local function ext_to_string(mode)
    local ft = ""
    for i, ext in pairs(extensions[mode]) do
        ext = "*." .. ext
        local comma = ","
        if i == #extensions then
            comma = " "
        end
        ft = ft .. ext .. comma
    end
    return AllTrim(ft)
end

StringExt["normal_ext"] = ext_to_string("normal")
--
Group = {}
-- FormatWrap = MakeFmtWrapper(filetype_config)
function FmtSetup()
    require("formatter").setup(
        {
            logging = false,
            filetype = ftconfig
        }
    )
    local hook = "BufWritePost"
    Group = {
        -- normal will use formatter plugins
        {hook, StringExt["normal_ext"], "FormatWrite"}
        -- manual is the custom one!
    }

    Group = Utils.table_merge(0, Group, init_manual(extensions["manual"], hook) or {})
    Create_augroup(Group, "FormatAutogroup")
end

Create_command("ExpandFormat", "print( vim.inspect(Group) )")
FmtSetup()
