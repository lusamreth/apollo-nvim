-- no need to export since this is all global
function AllTrim(s)
    return s:match("^%s*(.-)%s*$")
end

function firstToUpper(str)
    return (str:gsub("^%l", string.upper))
end
function IsUpperCase(ch)
    local charcode = string.byte(ch)
    return charcode >= 65 and charcode <= 90
end

function Sum(numarr)
    local z = 0
    vim.tbl_map(
        function(pad)
            z = z + pad
        end,
        numarr
    )
    return z
end
-- return table
function UpperCasePos(s, iterstop)
    local u, count = 1, 1
    local res = {}
    for c in s:gmatch "." do
        if IsUpperCase(c) then
            res[count] = u
            count = count + 1
            if iterstop == u then
                return res
            end
        end
        u = u + 1
    end

    return res
end

function Splitstr(str, delim)
    if str == nil or #str == 0 then
        return {}
    end

    local target = string.byte(delim)
    local i = 0
    local delim_local = {}

    for idx = 1, #str do
        if str:byte(idx) == target then
            delim_local[i] = idx
            i = i + 1
        end
    end

    local prev = 1
    for u = 0, #delim_local do
        local val = delim_local[u]
        delim_local[u] = string.sub(str, prev, val - 1)
        prev = val + 1
    end
    -- still final piece
    local final = string.sub(str, prev, #str)
    delim_local[#delim_local + 1] = final
    return delim_local
end

function Max(a)
    return vim.fn.max(a)
end
function Min(a)
    return vim.fn.min(a)
end

FindMax = function(nums)
    local max = 0
    for _, num in pairs(nums) do
        if max < num then
            max = num
        end
    end
    return max
end

function print_r(arr, indentLevel)
    local str = ""
    local indentStr = "#"

    if indentLevel == nil then
        print(print_r(arr, 0))
        return
    end

    for i = 0, indentLevel do
        indentStr = indentStr .. "\t"
    end

    for index, value in pairs(arr) do
        if type(value) == "table" then
            str = str .. indentStr .. index .. ": \n" .. print_r(value, (indentLevel + 1))
        else
            str = str .. indentStr .. index .. ": " .. value .. "\n"
        end
    end
    return str
end

Utils = {}

-- galaxyline module!
-- take a string form : "sign:color"
-- semantic : {
--   config[name="error?"] = {
--      sign = "",
--      color = ""
--   }
-- }
-- ]]

local diag_col = {
    red = "#e95678",
    redwine = "#d16d9e",
    light_green = "#abcf84",
    dark_green = "#98be65",
    brown = "#c78665",
    teal = "#1abc9c",
    yellow = "#f0c674",
    white = "#fff"
}

function FileType()
    return vim.fn.expand("%e")
end

function Create_augroup(autocmds, name)
    local cmd = vim.cmd
    cmd("augroup " .. name)
    cmd("autocmd!")
    for _, autocmd in ipairs(autocmds) do
        cmd("autocmd " .. table.concat(autocmd, " "))
    end
    cmd("augroup END")
end

-- taken from github but tweaked merge logic
-- original logic doesn't work well
-- also add depth level for unmerging

local function table_clone_internal(t, copies)
    if type(t) ~= "table" then
        return t
    end
    copies = copies or {}
    if copies[t] then
        return copies[t]
    end

    local copy = {}
    copies[t] = copy

    for k, v in pairs(t) do
        copy[table_clone_internal(k, copies)] = table_clone_internal(v, copies)
    end

    setmetatable(copy, table_clone_internal(getmetatable(t), copies))

    return copy
end

local function table_clone(t)
    -- We need to implement this with a helper function to make sure that
    -- user won't call this function with a second parameter as it can cause
    -- unexpected troubles
    return table_clone_internal(t)
end

-- only work with array
local function table_merge(level, ...)
    local tables_to_merge = {...}
    assert(#tables_to_merge > 1, "There should be at least two tables to merge them")
    for k, t in ipairs(tables_to_merge) do
        print(t[1])
        assert(type(t) == "table", string.format("Expected a table as function parameter %d", k))
    end

    --clone the initial element to merge tables
    local result = table_clone(tables_to_merge[1])

    local ecount = 0 -- element count
    local initial_len = #result
    for i = 2, #tables_to_merge do
        local from = tables_to_merge[i]

        -- probe over the remianing tables
        for _, v in pairs(from) do
            local function index()
                ecount = ecount + 1
                local res = ecount + initial_len
                return res
            end
            --print("e",ecount,k+initial_len)
            -- if discover nested table then merge them recursively
            if type(v) == "table" then
                local count = 0
                local function kchain(arg)
                    assert(type(arg) == "table", "Require table!")
                    for _, element in pairs(arg) do
                        local c = index()
                        --debuging
                        --print("e",element,i+count,i)
                        if type(element) == "table" and level ~= count then
                            kchain(element)
                            count = count + 1
                        else
                            result[c] = element
                        end
                    end
                end

                if level ~= count then
                    kchain(v)
                else
                    result[index()] = v
                end
            else
                result[index()] = v
            end
        end
    end

    return result
end

function Reverse(t)
    local n = #t
    local i = 1
    while i < n do
        t[i], t[n] = t[n], t[i]
        i = i + 1
        n = n - 1
    end
    return t
end

local charset = {}
do -- [0-9a-zA-Z]
    for c = 48, 57 do
        table.insert(charset, string.char(c))
    end
    for c = 65, 90 do
        table.insert(charset, string.char(c))
    end
    for c = 97, 122 do
        table.insert(charset, string.char(c))
    end
end

function RandomString(length)
    if not length or length <= 0 then
        return ""
    end
    math.randomseed(os.clock() ^ 5)
    return RandomString(length - 1) .. charset[math.random(1, #charset)]
end

Create_command = function(name, func)
    vim.cmd("command! -nargs=* " .. name .. " lua " .. func)
end
-- utils.galaxyline.default_diagnostic = default
Utils.table_merge = table_merge
return Utils
