PORT =
    interface.build_interface(
    {
        {"create_padding", {"number", "->", "string"}},
        -- text, dir,link_shape
        {"bullet_shape", {{"string", "string"}, "->", "table"}},
        {
            "make_corner",
            {"table", "->", "string"}
        }
    }
)

-- Require this
CORNER = {
    ROUND = {
        right = "",
        left = ""
    },
    ARROW = {
        right = "",
        left = ""
    },
    -- HEXARROW = {
    --     right = "",
    --     left = ""
    -- }
    HEXARROW = {
        right = "",
        left = ""
    }
}

--     ['n'] = { ' NORMAL', 'Normal' },
--     ['no'] = { ' O-PENDING', 'Visual' },
--     ['nov'] = { ' O-PENDING', 'Visual' },
--     ['noV'] = { ' O-PENDING', 'Visual' },
--     ['no'] = { ' O-PENDING', 'Visual' },
--     ['niI'] = { ' NORMAL', 'Normal' },
--     ['niR'] = { ' NORMAL', 'Normal' },
--     ['niV'] = { ' NORMAL', 'Normal' },
--     ['v'] = { ' VISUAL', 'Visual' },
--     ['V'] = { ' V-LINE', 'Visual' },
--     [''] = { ' V-BLOCK', 'Visual' },
--     ['s'] = { ' SELECT', 'Visual' },
--     ['S'] = { ' S-LINE', 'Visual' },
--     [''] = { ' S-BLOCK', 'Visual' },
--     ['i'] = { ' INSERT', 'Insert' },
--     ['ic'] = { ' INSERT', 'Insert' },
--     ['ix'] = { ' INSERT', 'Insert' },
--     ['R'] = { ' REPLACE', 'Replace' },
--     ['Rc'] = { ' REPLACE', 'Replace' },
--     ['Rv'] = { 'V-REPLACE', 'Normal' },
--     ['Rx'] = { ' REPLACE', 'Normal' },
--     ['c'] = { ' COMMAND', 'Command' },
--     ['cv'] = { ' COMMAND', 'Command' },
--     ['ce'] = { ' COMMAND', 'Command' },
--     ['r'] = { ' REPLACE', 'Replace' },
--     ['rm'] = { ' MORE', 'Normal' },
--     ['r?'] = { ' CONFIRM', 'Normal' },
--     ['!'] = { ' SHELL', 'Normal' },
--     ['t'] = { ' TERMINAL', 'Command' },
local check_dir = function(d)
    assert(d == "left" or d == "right", "Only support direction left or right!")
end

REND = {}
-- corner type for edge of bullet
REND.bullet_shape = function(dir, corner_type)
    check_dir(dir)

    local res = {
        head = CORNER[corner_type][dir]
    }

    local a = {1, 2}
    local pos = {
        head = 1,
        tail = 2
    }
    -- first case for left
    -- res["head"] = text
    -- res["tail"] = CORNER[corner_type][dir]
    if dir == "right" then
        Reverse(a)
    end
    --print("AAAA", a[1], a[2], text, dir)
    pos["head"] = a[1]
    pos["tail"] = a[2]
    res["pos"] = pos
    return res
end
-- rtype : ("type","dir"):("round","left")
-- type is all uppercase (ROUND,SHAPE,...)
REND.make_corner = function(rtype)
    assert(type(rtype) == "table")
    check_dir(rtype[2])
    return CORNER[rtype[1]][rtype[2]]
end

-- spaces : number
REND.create_padding = function(spaces)
    return string.rep(" ", spaces)
end

-- function TestRender()
--     print(REND.bullet_shape)
--     local l = REND.bullet_shape("text1", "left", "ROUND")
--     local r = REND.bullet_shape("text1", "right", "ROUND")
--     --assert(l == "text1" .. CORNER["ROUND"]["left"])
--     -- assert(l == ROUND_CORNER["left"])
-- end
return PORT.build(REND, false)
