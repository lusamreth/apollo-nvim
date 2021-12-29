_IMPORT = {}

_G.STATUSLINE_ROOT = "/home/lusamreth/nvim-proto-2/lua/core/statusline/"
_G.BEDROCK_ROOT = STATUSLINE_ROOT .. "bedrock/"
_IMPORT.root = STATUSLINE_ROOT

_G.import = function(mod, root)
    -- print("importing", mod)
    root = root or _IMPORT.root
    local succ, res = pcall(Splitstr, mod, ".")
    if succ == true then
        local full = ""
        -- print(#res, res[1], res[2])
        for i, p in pairs(res) do
            local suffix = "/"
            if i == #res then
                suffix = ""
            end
            full = full .. p .. suffix
        end
        mod = full
    end
    local f, e = loadfile(root .. mod .. ".lua")
    if e then
        error("has error importing\n" .. e)
    end
    return f()
end

Oimport = _G.import
-- if use the _G.import it will freeze !
import("containers.init")
